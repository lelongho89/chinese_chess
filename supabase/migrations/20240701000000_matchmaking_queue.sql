-- Create matchmaking_queue table
CREATE TABLE IF NOT EXISTS public.matchmaking_queue (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  elo_rating INTEGER NOT NULL,
  queue_type TEXT NOT NULL DEFAULT 'ranked', -- 'ranked', 'casual', 'tournament'
  time_control INTEGER NOT NULL DEFAULT 180, -- Time control in seconds (3 minutes default)
  preferred_color TEXT, -- 'red', 'black', null for no preference
  max_elo_difference INTEGER NOT NULL DEFAULT 200, -- Maximum Elo difference for matching
  status TEXT NOT NULL DEFAULT 'waiting', -- 'waiting', 'matched', 'cancelled', 'expired'
  matched_with_user_id UUID REFERENCES public.users(id),
  match_id UUID REFERENCES public.games(id),
  joined_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  matched_at TIMESTAMP WITH TIME ZONE,
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT (NOW() + INTERVAL '10 minutes'),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
  metadata JSONB
);

-- Create leaderboard table (if not exists)
CREATE TABLE IF NOT EXISTS public.leaderboard (
  id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  display_name TEXT NOT NULL,
  elo_rating INTEGER NOT NULL DEFAULT 1200,
  rank INTEGER NOT NULL DEFAULT 0,
  games_played INTEGER NOT NULL DEFAULT 0,
  games_won INTEGER NOT NULL DEFAULT 0,
  games_lost INTEGER NOT NULL DEFAULT 0,
  games_draw INTEGER NOT NULL DEFAULT 0,
  win_rate REAL NOT NULL DEFAULT 0.0,
  last_updated TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  metadata JSONB,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  is_deleted BOOLEAN NOT NULL DEFAULT FALSE
);

-- Enable RLS for matchmaking_queue
ALTER TABLE public.matchmaking_queue ENABLE ROW LEVEL SECURITY;

-- Enable RLS for leaderboard
ALTER TABLE public.leaderboard ENABLE ROW LEVEL SECURITY;

-- Matchmaking queue policies
CREATE POLICY "Users can read their own queue entries" ON public.matchmaking_queue
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own queue entries" ON public.matchmaking_queue
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own queue entries" ON public.matchmaking_queue
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own queue entries" ON public.matchmaking_queue
  FOR DELETE USING (auth.uid() = user_id);

-- Leaderboard policies
CREATE POLICY "Users can read leaderboard" ON public.leaderboard
  FOR SELECT USING (true);

CREATE POLICY "System can manage leaderboard" ON public.leaderboard
  FOR ALL USING (true);

-- Create indexes for efficient matchmaking
CREATE INDEX IF NOT EXISTS matchmaking_queue_user_id_idx ON public.matchmaking_queue(user_id);
CREATE INDEX IF NOT EXISTS matchmaking_queue_status_idx ON public.matchmaking_queue(status);
CREATE INDEX IF NOT EXISTS matchmaking_queue_elo_rating_idx ON public.matchmaking_queue(elo_rating);
CREATE INDEX IF NOT EXISTS matchmaking_queue_queue_type_idx ON public.matchmaking_queue(queue_type);
CREATE INDEX IF NOT EXISTS matchmaking_queue_joined_at_idx ON public.matchmaking_queue(joined_at);
CREATE INDEX IF NOT EXISTS matchmaking_queue_expires_at_idx ON public.matchmaking_queue(expires_at);

-- Composite index for efficient Elo-based matching
CREATE INDEX IF NOT EXISTS matchmaking_queue_matching_idx ON public.matchmaking_queue(
  status, queue_type, elo_rating, joined_at
) WHERE status = 'waiting' AND is_deleted = false;

-- Leaderboard indexes
CREATE INDEX IF NOT EXISTS leaderboard_elo_rating_idx ON public.leaderboard(elo_rating DESC);
CREATE INDEX IF NOT EXISTS leaderboard_rank_idx ON public.leaderboard(rank);
CREATE INDEX IF NOT EXISTS leaderboard_user_id_idx ON public.leaderboard(user_id);

-- Function to automatically expire old queue entries
CREATE OR REPLACE FUNCTION expire_old_queue_entries()
RETURNS void AS $$
BEGIN
  UPDATE public.matchmaking_queue
  SET status = 'expired', updated_at = NOW()
  WHERE status = 'waiting'
    AND expires_at < NOW()
    AND is_deleted = false;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to clean up expired entries (run periodically)
CREATE OR REPLACE FUNCTION cleanup_expired_queue_entries()
RETURNS void AS $$
BEGIN
  UPDATE public.matchmaking_queue
  SET is_deleted = true, updated_at = NOW()
  WHERE status IN ('expired', 'cancelled', 'matched')
    AND updated_at < NOW() - INTERVAL '1 hour';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to find potential matches based on Elo proximity
CREATE OR REPLACE FUNCTION find_potential_matches(
  target_user_id UUID,
  target_elo INTEGER,
  target_queue_type TEXT,
  max_elo_diff INTEGER DEFAULT 200
)
RETURNS TABLE(
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
  WHERE mq.status = 'waiting'
    AND mq.is_deleted = false
    AND mq.user_id != target_user_id
    AND mq.queue_type = target_queue_type
    AND ABS(mq.elo_rating - target_elo) <= GREATEST(max_elo_diff, mq.max_elo_difference)
    AND mq.expires_at > NOW()
  ORDER BY
    ABS(mq.elo_rating - target_elo) ASC,  -- Prefer closer Elo ratings
    mq.joined_at ASC                      -- Prefer players who have been waiting longer
  LIMIT 10;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Add real-time game state fields to games table
ALTER TABLE public.games ADD COLUMN IF NOT EXISTS current_fen TEXT DEFAULT 'rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR';
ALTER TABLE public.games ADD COLUMN IF NOT EXISTS current_player INTEGER DEFAULT 0; -- 0 for red, 1 for black
ALTER TABLE public.games ADD COLUMN IF NOT EXISTS game_status TEXT DEFAULT 'active'; -- 'active', 'paused', 'ended'
ALTER TABLE public.games ADD COLUMN IF NOT EXISTS last_move TEXT;
ALTER TABLE public.games ADD COLUMN IF NOT EXISTS last_move_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE public.games ADD COLUMN IF NOT EXISTS connection_status JSONB DEFAULT '{"red": "connected", "black": "connected"}';

-- Create game_moves table for real-time move tracking
CREATE TABLE IF NOT EXISTS public.game_moves (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  game_id UUID NOT NULL REFERENCES public.games(id) ON DELETE CASCADE,
  player_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  move_number INTEGER NOT NULL,
  move_notation TEXT NOT NULL, -- e.g., "e2e4"
  fen_after_move TEXT NOT NULL,
  time_remaining INTEGER NOT NULL, -- seconds remaining for the player
  move_time INTEGER NOT NULL, -- time taken for this move in milliseconds
  is_check BOOLEAN DEFAULT FALSE,
  is_checkmate BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  metadata JSONB
);

-- Enable RLS for game_moves
ALTER TABLE public.game_moves ENABLE ROW LEVEL SECURITY;

-- Game moves policies
CREATE POLICY "Players can read moves from their games" ON public.game_moves
  FOR SELECT USING (
    game_id IN (
      SELECT id FROM public.games
      WHERE red_player_id = auth.uid() OR black_player_id = auth.uid()
    )
  );

CREATE POLICY "Players can insert moves to their games" ON public.game_moves
  FOR INSERT WITH CHECK (
    player_id = auth.uid() AND
    game_id IN (
      SELECT id FROM public.games
      WHERE red_player_id = auth.uid() OR black_player_id = auth.uid()
    )
  );

-- Indexes for game_moves
CREATE INDEX IF NOT EXISTS game_moves_game_id_idx ON public.game_moves(game_id);
CREATE INDEX IF NOT EXISTS game_moves_player_id_idx ON public.game_moves(player_id);
CREATE INDEX IF NOT EXISTS game_moves_move_number_idx ON public.game_moves(game_id, move_number);
CREATE INDEX IF NOT EXISTS game_moves_created_at_idx ON public.game_moves(created_at);

-- Function to update game state when a move is made
CREATE OR REPLACE FUNCTION update_game_state_on_move()
RETURNS TRIGGER AS $$
BEGIN
  -- Update the games table with the latest move information
  UPDATE public.games
  SET
    current_fen = NEW.fen_after_move,
    current_player = CASE
      WHEN current_player = 0 THEN 1
      ELSE 0
    END,
    last_move = NEW.move_notation,
    last_move_at = NEW.created_at,
    move_count = NEW.move_number,
    red_time_remaining = CASE
      WHEN NEW.player_id = red_player_id THEN NEW.time_remaining
      ELSE red_time_remaining
    END,
    black_time_remaining = CASE
      WHEN NEW.player_id = black_player_id THEN NEW.time_remaining
      ELSE black_time_remaining
    END,
    updated_at = NOW()
  WHERE id = NEW.game_id;

  -- Check for game end conditions
  IF NEW.is_checkmate THEN
    UPDATE public.games
    SET
      game_status = 'ended',
      winner_id = NEW.player_id,
      ended_at = NOW()
    WHERE id = NEW.game_id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for automatic game state updates
DROP TRIGGER IF EXISTS trigger_update_game_state_on_move ON public.game_moves;
CREATE TRIGGER trigger_update_game_state_on_move
  AFTER INSERT ON public.game_moves
  FOR EACH ROW
  EXECUTE FUNCTION update_game_state_on_move();
