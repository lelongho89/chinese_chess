-- Create users table
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  display_name TEXT NOT NULL,
  elo_rating INTEGER NOT NULL DEFAULT 1200,
  games_played INTEGER NOT NULL DEFAULT 0,
  games_won INTEGER NOT NULL DEFAULT 0,
  games_lost INTEGER NOT NULL DEFAULT 0,
  games_draw INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  last_login_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  is_deleted BOOLEAN NOT NULL DEFAULT FALSE
);

-- Create friends table
CREATE TABLE IF NOT EXISTS public.friends (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  friend_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, friend_id)
);

-- Create games table
CREATE TABLE IF NOT EXISTS public.games (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  red_player_id UUID NOT NULL REFERENCES public.users(id),
  black_player_id UUID NOT NULL REFERENCES public.users(id),
  winner_id UUID REFERENCES public.users(id),
  is_draw BOOLEAN NOT NULL DEFAULT FALSE,
  move_count INTEGER NOT NULL DEFAULT 0,
  moves JSONB NOT NULL DEFAULT '[]'::JSONB,
  final_fen TEXT NOT NULL DEFAULT '',
  red_time_remaining INTEGER NOT NULL DEFAULT 180,
  black_time_remaining INTEGER NOT NULL DEFAULT 180,
  started_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  ended_at TIMESTAMP WITH TIME ZONE,
  is_ranked BOOLEAN NOT NULL DEFAULT TRUE,
  tournament_id UUID,
  metadata JSONB,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  is_deleted BOOLEAN NOT NULL DEFAULT FALSE
);

-- Create tournaments table
CREATE TABLE IF NOT EXISTS public.tournaments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  creator_id UUID NOT NULL REFERENCES public.users(id),
  max_participants INTEGER NOT NULL DEFAULT 8,
  status INTEGER NOT NULL DEFAULT 0,
  type INTEGER NOT NULL DEFAULT 0,
  start_time TIMESTAMP WITH TIME ZONE NOT NULL,
  end_time TIMESTAMP WITH TIME ZONE,
  brackets JSONB NOT NULL DEFAULT '{}'::JSONB,
  settings JSONB,
  metadata JSONB,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  is_deleted BOOLEAN NOT NULL DEFAULT FALSE
);

-- Create tournament_participants table
CREATE TABLE IF NOT EXISTS public.tournament_participants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tournament_id UUID NOT NULL REFERENCES public.tournaments(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  UNIQUE(tournament_id, user_id)
);

-- Create matches table
CREATE TABLE IF NOT EXISTS public.matches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tournament_id UUID NOT NULL REFERENCES public.tournaments(id) ON DELETE CASCADE,
  round INTEGER NOT NULL,
  position INTEGER NOT NULL,
  player1_id UUID REFERENCES public.users(id),
  player2_id UUID REFERENCES public.users(id),
  winner_id UUID REFERENCES public.users(id),
  game_id UUID REFERENCES public.games(id),
  status INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  is_deleted BOOLEAN NOT NULL DEFAULT FALSE
);

-- Create RLS policies
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.friends ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.games ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tournaments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tournament_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.matches ENABLE ROW LEVEL SECURITY;

-- Users policies
CREATE POLICY "Users can read their own data" ON public.users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can read other users' public data" ON public.users
  FOR SELECT USING (true);

CREATE POLICY "Users can update their own data" ON public.users
  FOR UPDATE USING (auth.uid() = id);

-- Friends policies
CREATE POLICY "Users can read their own friends" ON public.friends
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can add friends" ON public.friends
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can remove their own friends" ON public.friends
  FOR DELETE USING (auth.uid() = user_id);

-- Games policies
CREATE POLICY "Users can read their own games" ON public.games
  FOR SELECT USING (auth.uid() = red_player_id OR auth.uid() = black_player_id);

CREATE POLICY "Users can read public games" ON public.games
  FOR SELECT USING (true);

CREATE POLICY "Users can create games" ON public.games
  FOR INSERT WITH CHECK (auth.uid() = red_player_id OR auth.uid() = black_player_id);

CREATE POLICY "Users can update their own games" ON public.games
  FOR UPDATE USING (auth.uid() = red_player_id OR auth.uid() = black_player_id);

-- Tournaments policies
CREATE POLICY "Users can read tournaments" ON public.tournaments
  FOR SELECT USING (true);

CREATE POLICY "Users can create tournaments" ON public.tournaments
  FOR INSERT WITH CHECK (auth.uid() = creator_id);

CREATE POLICY "Users can update their own tournaments" ON public.tournaments
  FOR UPDATE USING (auth.uid() = creator_id);

-- Tournament participants policies
CREATE POLICY "Users can read tournament participants" ON public.tournament_participants
  FOR SELECT USING (true);

CREATE POLICY "Users can join tournaments" ON public.tournament_participants
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can leave tournaments" ON public.tournament_participants
  FOR DELETE USING (auth.uid() = user_id);

-- Matches policies
CREATE POLICY "Users can read matches" ON public.matches
  FOR SELECT USING (true);

-- Create functions and triggers
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, display_name, created_at, last_login_at)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1)),
    NOW(),
    NOW()
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
