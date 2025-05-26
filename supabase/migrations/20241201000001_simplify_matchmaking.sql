-- Simplify matchmaking by removing side preferences and using single time control
-- This migration removes the preferred_color column and updates related functions

-- Remove the preferred_color column from matchmaking_queue table
ALTER TABLE public.matchmaking_queue 
DROP COLUMN IF EXISTS preferred_color;

-- Add comment explaining the simplified matchmaking approach
COMMENT ON TABLE public.matchmaking_queue IS 'Simplified matchmaking queue - side assignment handled by SideAlternationService, time control configured in app';

-- Update the find_potential_matches function to remove color preference logic
CREATE OR REPLACE FUNCTION find_potential_matches(
  target_user_id UUID,
  target_elo INTEGER,
  target_queue_type TEXT,
  max_elo_diff INTEGER DEFAULT 200
)
RETURNS TABLE (
  queue_id UUID,
  user_id UUID,
  elo_rating INTEGER,
  elo_difference INTEGER,
  wait_time_seconds INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    mq.id as queue_id,
    mq.user_id,
    mq.elo_rating,
    ABS(mq.elo_rating - target_elo) as elo_difference,
    EXTRACT(EPOCH FROM (NOW() - mq.joined_at))::INTEGER as wait_time_seconds
  FROM public.matchmaking_queue mq
  WHERE 
    mq.user_id != target_user_id
    AND mq.status = 'waiting'
    AND mq.queue_type = target_queue_type
    AND mq.is_deleted = FALSE
    AND mq.expires_at > NOW()
    AND ABS(mq.elo_rating - target_elo) <= max_elo_diff
  ORDER BY 
    elo_difference ASC,
    mq.joined_at ASC
  LIMIT 10;
END;
$$ LANGUAGE plpgsql;

-- Update queue statistics function to reflect simplified structure
CREATE OR REPLACE FUNCTION get_queue_statistics()
RETURNS TABLE (
  total_waiting INTEGER,
  ranked_waiting INTEGER,
  casual_waiting INTEGER,
  tournament_waiting INTEGER,
  average_wait_time_seconds INTEGER,
  average_elo INTEGER,
  elo_distribution JSONB
) AS $$
DECLARE
  wait_times INTEGER[];
  elos INTEGER[];
BEGIN
  -- Get basic counts
  SELECT 
    COUNT(*),
    COUNT(*) FILTER (WHERE queue_type = 'ranked'),
    COUNT(*) FILTER (WHERE queue_type = 'casual'),
    COUNT(*) FILTER (WHERE queue_type = 'tournament'),
    ARRAY_AGG(EXTRACT(EPOCH FROM (NOW() - joined_at))::INTEGER),
    ARRAY_AGG(elo_rating)
  INTO 
    total_waiting,
    ranked_waiting,
    casual_waiting,
    tournament_waiting,
    wait_times,
    elos
  FROM public.matchmaking_queue
  WHERE 
    status = 'waiting'
    AND is_deleted = FALSE
    AND expires_at > NOW();

  -- Calculate averages
  IF total_waiting > 0 THEN
    SELECT 
      (SELECT AVG(unnest) FROM unnest(wait_times))::INTEGER,
      (SELECT AVG(unnest) FROM unnest(elos))::INTEGER
    INTO average_wait_time_seconds, average_elo;
  ELSE
    average_wait_time_seconds := 0;
    average_elo := 1200;
  END IF;

  -- Calculate Elo distribution
  SELECT jsonb_build_object(
    'under_1000', COUNT(*) FILTER (WHERE elo_rating < 1000),
    '1000_1199', COUNT(*) FILTER (WHERE elo_rating >= 1000 AND elo_rating < 1200),
    '1200_1399', COUNT(*) FILTER (WHERE elo_rating >= 1200 AND elo_rating < 1400),
    '1400_1599', COUNT(*) FILTER (WHERE elo_rating >= 1400 AND elo_rating < 1600),
    '1600_1799', COUNT(*) FILTER (WHERE elo_rating >= 1600 AND elo_rating < 1800),
    '1800_1999', COUNT(*) FILTER (WHERE elo_rating >= 1800 AND elo_rating < 2000),
    'over_2000', COUNT(*) FILTER (WHERE elo_rating >= 2000)
  )
  INTO elo_distribution
  FROM public.matchmaking_queue
  WHERE 
    status = 'waiting'
    AND is_deleted = FALSE
    AND expires_at > NOW();

  RETURN QUERY SELECT 
    total_waiting,
    ranked_waiting,
    casual_waiting,
    tournament_waiting,
    average_wait_time_seconds,
    average_elo,
    elo_distribution;
END;
$$ LANGUAGE plpgsql;

-- Create a function to get simplified matchmaking configuration
CREATE OR REPLACE FUNCTION get_matchmaking_config()
RETURNS TABLE (
  default_time_control INTEGER,
  max_elo_difference INTEGER,
  queue_timeout_minutes INTEGER,
  ai_spawn_delay_seconds INTEGER,
  side_alternation_enabled BOOLEAN
) AS $$
BEGIN
  -- Return hardcoded configuration values
  -- These can be made configurable via a settings table in the future
  RETURN QUERY SELECT 
    300 as default_time_control,        -- 5 minutes
    200 as max_elo_difference,          -- 200 Elo points
    10 as queue_timeout_minutes,        -- 10 minutes
    10 as ai_spawn_delay_seconds,       -- 10 seconds
    TRUE as side_alternation_enabled;   -- Side alternation enabled
END;
$$ LANGUAGE plpgsql;

-- Create a view for simplified queue monitoring
CREATE OR REPLACE VIEW simplified_queue_view AS
SELECT 
  mq.id,
  mq.user_id,
  u.display_name,
  mq.elo_rating,
  mq.queue_type,
  mq.time_control,
  mq.status,
  mq.joined_at,
  mq.expires_at,
  EXTRACT(EPOCH FROM (NOW() - mq.joined_at))::INTEGER as wait_time_seconds,
  EXTRACT(EPOCH FROM (mq.expires_at - NOW()))::INTEGER as expires_in_seconds,
  -- Side alternation info
  u.last_played_side,
  u.red_games_played,
  u.black_games_played,
  CASE 
    WHEN (u.red_games_played + u.black_games_played) > 0 
    THEN ROUND(u.red_games_played::DECIMAL / (u.red_games_played + u.black_games_played), 3)
    ELSE 0.5 
  END as red_ratio
FROM public.matchmaking_queue mq
LEFT JOIN public.users u ON mq.user_id = u.id
WHERE mq.is_deleted = FALSE
ORDER BY mq.joined_at;

-- Grant permissions
GRANT EXECUTE ON FUNCTION find_potential_matches(UUID, INTEGER, TEXT, INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION get_queue_statistics() TO authenticated;
GRANT EXECUTE ON FUNCTION get_matchmaking_config() TO authenticated;
GRANT SELECT ON simplified_queue_view TO authenticated;

-- Add RLS policy for the view
CREATE POLICY "Users can view simplified queue" ON public.matchmaking_queue
  FOR SELECT USING (true); -- Allow all authenticated users to view queue for statistics

-- Update existing queue entries to remove any null time_control values
UPDATE public.matchmaking_queue 
SET time_control = 300 
WHERE time_control IS NULL OR time_control = 0;

-- Add constraint to ensure time_control is always positive
ALTER TABLE public.matchmaking_queue 
ADD CONSTRAINT check_time_control_positive 
CHECK (time_control > 0);

-- Add index for efficient queue queries without color preference
CREATE INDEX IF NOT EXISTS idx_matchmaking_queue_simplified 
ON public.matchmaking_queue (queue_type, status, elo_rating, joined_at) 
WHERE is_deleted = FALSE;

-- Drop old index that included preferred_color if it exists
DROP INDEX IF EXISTS idx_matchmaking_queue_color_preference;

-- Add helpful comments
COMMENT ON FUNCTION find_potential_matches IS 'Find potential matches without color preferences - simplified matchmaking';
COMMENT ON FUNCTION get_queue_statistics IS 'Get comprehensive queue statistics for simplified matchmaking';
COMMENT ON FUNCTION get_matchmaking_config IS 'Get current matchmaking configuration values';
COMMENT ON VIEW simplified_queue_view IS 'Simplified view of matchmaking queue with side alternation data';

-- Create a trigger to automatically set time_control from app config
CREATE OR REPLACE FUNCTION set_default_time_control()
RETURNS TRIGGER AS $$
BEGIN
  -- Set default time control if not provided
  IF NEW.time_control IS NULL OR NEW.time_control = 0 THEN
    NEW.time_control := 300; -- 5 minutes default
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to matchmaking_queue table
DROP TRIGGER IF EXISTS trigger_set_default_time_control ON public.matchmaking_queue;
CREATE TRIGGER trigger_set_default_time_control
  BEFORE INSERT ON public.matchmaking_queue
  FOR EACH ROW
  EXECUTE FUNCTION set_default_time_control();

-- Log the migration
INSERT INTO public.audit_log (
  table_name,
  operation,
  record_id,
  changes,
  created_at
) VALUES (
  'matchmaking_queue',
  'schema_simplification',
  NULL,
  jsonb_build_object(
    'migration', '20241201000001_simplify_matchmaking',
    'changes', ARRAY[
      'removed_preferred_color_column',
      'updated_find_potential_matches_function',
      'created_simplified_queue_view',
      'added_default_time_control_trigger'
    ],
    'reason', 'Simplified matchmaking with single time control and automatic side alternation'
  ),
  NOW()
);
