-- Add side alternation tracking fields to users table
-- This migration adds fields to track which side (Red/Black) players have played
-- to ensure fair alternation in consecutive matches

-- Add side tracking columns to users table
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS last_played_side TEXT CHECK (last_played_side IN ('red', 'black')),
ADD COLUMN IF NOT EXISTS red_games_played INTEGER NOT NULL DEFAULT 0,
ADD COLUMN IF NOT EXISTS black_games_played INTEGER NOT NULL DEFAULT 0;

-- Add comments for documentation
COMMENT ON COLUMN public.users.last_played_side IS 'Tracks the last side (red/black) the player played for alternation';
COMMENT ON COLUMN public.users.red_games_played IS 'Count of games played as Red player';
COMMENT ON COLUMN public.users.black_games_played IS 'Count of games played as Black player';

-- Create index for efficient side alternation queries
CREATE INDEX IF NOT EXISTS idx_users_side_tracking 
ON public.users (last_played_side, red_games_played, black_games_played);

-- Create a function to get side alternation statistics
CREATE OR REPLACE FUNCTION get_user_side_stats(user_id UUID)
RETURNS TABLE (
  total_games INTEGER,
  red_games INTEGER,
  black_games INTEGER,
  red_ratio DECIMAL,
  last_side TEXT,
  should_alternate BOOLEAN,
  preferred_next_side TEXT
) AS $$
DECLARE
  user_record RECORD;
  total_side_games INTEGER;
  calculated_red_ratio DECIMAL;
BEGIN
  -- Get user data
  SELECT 
    games_played,
    red_games_played,
    black_games_played,
    last_played_side
  INTO user_record
  FROM public.users
  WHERE id = user_id;
  
  -- Calculate totals
  total_side_games := COALESCE(user_record.red_games_played, 0) + COALESCE(user_record.black_games_played, 0);
  
  -- Calculate red ratio
  IF total_side_games > 0 THEN
    calculated_red_ratio := ROUND(COALESCE(user_record.red_games_played, 0)::DECIMAL / total_side_games, 3);
  ELSE
    calculated_red_ratio := 0.5;
  END IF;
  
  -- Return results
  RETURN QUERY SELECT
    COALESCE(user_record.games_played, 0) as total_games,
    COALESCE(user_record.red_games_played, 0) as red_games,
    COALESCE(user_record.black_games_played, 0) as black_games,
    calculated_red_ratio as red_ratio,
    user_record.last_played_side as last_side,
    -- Should alternate if played same side 70% or more of the time (and at least 2 games)
    (total_side_games >= 2 AND (calculated_red_ratio >= 0.7 OR calculated_red_ratio <= 0.3)) as should_alternate,
    -- Preferred next side is opposite of what they played more
    CASE 
      WHEN user_record.last_played_side = 'red' THEN 'black'
      WHEN user_record.last_played_side = 'black' THEN 'red'
      WHEN calculated_red_ratio > 0.5 THEN 'black'
      ELSE 'red'
    END as preferred_next_side;
END;
$$ LANGUAGE plpgsql;

-- Create a function to update side history after a game
CREATE OR REPLACE FUNCTION update_player_side_history(
  player_id UUID,
  played_side TEXT
) RETURNS VOID AS $$
BEGIN
  -- Validate side parameter
  IF played_side NOT IN ('red', 'black') THEN
    RAISE EXCEPTION 'Invalid side: %. Must be red or black', played_side;
  END IF;
  
  -- Update the user's side history
  UPDATE public.users 
  SET 
    last_played_side = played_side,
    red_games_played = CASE 
      WHEN played_side = 'red' THEN COALESCE(red_games_played, 0) + 1 
      ELSE COALESCE(red_games_played, 0) 
    END,
    black_games_played = CASE 
      WHEN played_side = 'black' THEN COALESCE(black_games_played, 0) + 1 
      ELSE COALESCE(black_games_played, 0) 
    END,
    updated_at = NOW()
  WHERE id = player_id;
  
  -- Log the update
  INSERT INTO public.audit_log (
    table_name,
    operation,
    record_id,
    changes,
    created_at
  ) VALUES (
    'users',
    'side_history_update',
    player_id,
    jsonb_build_object(
      'played_side', played_side,
      'timestamp', NOW()
    ),
    NOW()
  );
  
EXCEPTION
  WHEN OTHERS THEN
    -- Log error but don't fail the transaction
    RAISE WARNING 'Error updating side history for player %: %', player_id, SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- Create audit log table if it doesn't exist (for tracking side history changes)
CREATE TABLE IF NOT EXISTS public.audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  table_name TEXT NOT NULL,
  operation TEXT NOT NULL,
  record_id UUID,
  changes JSONB,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Create index on audit log for efficient queries
CREATE INDEX IF NOT EXISTS idx_audit_log_table_operation 
ON public.audit_log (table_name, operation, created_at);

-- Grant necessary permissions
GRANT EXECUTE ON FUNCTION get_user_side_stats(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION update_player_side_history(UUID, TEXT) TO authenticated;

-- Add RLS policies for audit log
ALTER TABLE public.audit_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own audit logs" ON public.audit_log
  FOR SELECT USING (record_id = auth.uid());

-- Update existing users to have default side tracking values
UPDATE public.users 
SET 
  red_games_played = 0,
  black_games_played = 0
WHERE 
  red_games_played IS NULL 
  OR black_games_played IS NULL;

-- Add a trigger to automatically update side history when games are completed
-- This will be called from the application, but we can also have a database trigger as backup

CREATE OR REPLACE FUNCTION trigger_update_side_history()
RETURNS TRIGGER AS $$
BEGIN
  -- Only process when a game is completed (ended_at is set)
  IF NEW.ended_at IS NOT NULL AND OLD.ended_at IS NULL THEN
    -- Update red player side history
    PERFORM update_player_side_history(NEW.red_player_id, 'red');
    
    -- Update black player side history  
    PERFORM update_player_side_history(NEW.black_player_id, 'black');
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger on games table
DROP TRIGGER IF EXISTS trigger_game_completion_side_history ON public.games;
CREATE TRIGGER trigger_game_completion_side_history
  AFTER UPDATE ON public.games
  FOR EACH ROW
  EXECUTE FUNCTION trigger_update_side_history();

-- Add helpful views for side alternation analysis
CREATE OR REPLACE VIEW user_side_balance AS
SELECT 
  u.id,
  u.display_name,
  u.games_played,
  u.red_games_played,
  u.black_games_played,
  u.last_played_side,
  CASE 
    WHEN (u.red_games_played + u.black_games_played) > 0 
    THEN ROUND(u.red_games_played::DECIMAL / (u.red_games_played + u.black_games_played), 3)
    ELSE 0.5 
  END as red_ratio,
  CASE 
    WHEN (u.red_games_played + u.black_games_played) >= 2 
    THEN (
      ROUND(u.red_games_played::DECIMAL / (u.red_games_played + u.black_games_played), 3) >= 0.7 
      OR ROUND(u.red_games_played::DECIMAL / (u.red_games_played + u.black_games_played), 3) <= 0.3
    )
    ELSE FALSE 
  END as should_alternate
FROM public.users u
WHERE u.is_deleted = FALSE
ORDER BY u.games_played DESC;

-- Grant access to the view
GRANT SELECT ON user_side_balance TO authenticated;
