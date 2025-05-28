-- Update matchmaking system for 5+3 time control and match confirmation
-- Migrate matchmaking_queue to support 5+3 time control and pending confirmation state

-- Update default time control to 5 minutes (300 seconds)
ALTER TABLE public.matchmaking_queue 
  ALTER COLUMN time_control SET DEFAULT 300;

-- Add pending confirmation timeout timestamp
ALTER TABLE public.matchmaking_queue 
  ADD COLUMN confirmation_expires_at TIMESTAMP WITH TIME ZONE;

-- Add increment seconds for 5+3 time control
ALTER TABLE public.matchmaking_queue 
  ADD COLUMN increment_seconds INTEGER NOT NULL DEFAULT 3;

-- Update the status enum to include pending_confirmation
ALTER TYPE public.match_status ADD VALUE IF NOT EXISTS 'pending_confirmation';

-- Add confirmation status columns
ALTER TABLE public.matchmaking_queue 
  ADD COLUMN is_confirmed BOOLEAN DEFAULT FALSE,
  ADD COLUMN confirmation_time TIMESTAMP WITH TIME ZONE;

-- Function to handle match confirmation timeout
CREATE OR REPLACE FUNCTION handle_confirmation_timeout() RETURNS void AS $$
BEGIN
  -- Cancel matches where confirmation has expired
  UPDATE public.matchmaking_queue
  SET status = 'cancelled',
      updated_at = NOW()
  WHERE status = 'pending_confirmation'
    AND confirmation_expires_at < NOW();
END;
$$ LANGUAGE plpgsql;

-- Create a trigger to automatically clean up expired confirmations
CREATE OR REPLACE FUNCTION auto_cleanup_expired_confirmations()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'pending_confirmation' THEN
    NEW.confirmation_expires_at := NOW() + INTERVAL '10 seconds';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_set_confirmation_expires
  BEFORE INSERT OR UPDATE ON public.matchmaking_queue
  FOR EACH ROW
  WHEN (NEW.status = 'pending_confirmation')
  EXECUTE FUNCTION auto_cleanup_expired_confirmations();

-- Add index for efficient confirmation expiry checks
CREATE INDEX IF NOT EXISTS idx_matchmaking_queue_confirmation_expires 
ON public.matchmaking_queue(confirmation_expires_at) 
WHERE status = 'pending_confirmation';

-- Update or create the find_potential_matches function to handle increment seconds
CREATE OR REPLACE FUNCTION find_potential_matches(
  target_user_id UUID,
  target_elo INTEGER,
  target_queue_type TEXT,
  max_elo_diff INTEGER
) RETURNS TABLE (
  queue_id TEXT,
  user_id TEXT,
  elo_rating INTEGER,
  elo_difference INTEGER,
  wait_time_seconds INTEGER,
  increment_seconds INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    mq.id::TEXT,
    mq.user_id::TEXT,
    mq.elo_rating,
    ABS(mq.elo_rating - target_elo),
    EXTRACT(EPOCH FROM (NOW() - mq.joined_at))::INTEGER,
    mq.increment_seconds
  FROM matchmaking_queue mq
  WHERE mq.status = 'waiting'
    AND mq.is_deleted = FALSE
    AND mq.user_id != target_user_id
    AND mq.queue_type = target_queue_type
    AND ABS(mq.elo_rating - target_elo) <= max_elo_diff
  ORDER BY ABS(mq.elo_rating - target_elo), mq.joined_at;
END;
$$ LANGUAGE plpgsql;
