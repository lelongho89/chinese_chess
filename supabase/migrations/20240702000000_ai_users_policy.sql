-- Create function to insert AI test users (bypasses RLS)
CREATE OR REPLACE FUNCTION public.create_ai_user(
  user_id UUID,
  user_email TEXT,
  display_name TEXT,
  elo_rating INTEGER DEFAULT 1200,
  games_played INTEGER DEFAULT 0,
  games_won INTEGER DEFAULT 0,
  games_lost INTEGER DEFAULT 0,
  games_draw INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_login_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
)
RETURNS UUID AS $$
BEGIN
  -- Only allow creation of AI users (emails ending with @aitest.com)
  IF user_email NOT LIKE '%@aitest.com' THEN
    RAISE EXCEPTION 'This function can only create AI test users';
  END IF;

  -- Insert the AI user directly (bypasses RLS)
  INSERT INTO public.users (
    id, email, display_name, elo_rating, games_played,
    games_won, games_lost, games_draw, created_at, last_login_at, is_anonymous
  ) VALUES (
    user_id, user_email, display_name, elo_rating, games_played,
    games_won, games_lost, games_draw, created_at, last_login_at, false
  );

  RETURN user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to delete all AI test users
CREATE OR REPLACE FUNCTION public.delete_all_ai_users()
RETURNS INTEGER AS $$
DECLARE
  deleted_count INTEGER;
BEGIN
  -- Delete all users with @aitest.com emails
  DELETE FROM public.users
  WHERE email LIKE '%@aitest.com';

  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  RETURN deleted_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permissions to authenticated users
GRANT EXECUTE ON FUNCTION public.create_ai_user TO authenticated;
GRANT EXECUTE ON FUNCTION public.delete_all_ai_users TO authenticated;

-- Create function to add AI users to matchmaking queue (bypasses RLS)
CREATE OR REPLACE FUNCTION public.add_ai_user_to_queue(
  queue_id UUID,
  user_id UUID,
  user_elo INTEGER,
  queue_type TEXT DEFAULT 'ranked',
  time_control INTEGER DEFAULT 180,
  preferred_color TEXT DEFAULT NULL,
  max_elo_difference INTEGER DEFAULT 200
)
RETURNS UUID AS $$
BEGIN
  -- Only allow AI users (check if user exists and has @aitest.com email)
  IF NOT EXISTS (
    SELECT 1 FROM public.users
    WHERE id = user_id AND email LIKE '%@aitest.com'
  ) THEN
    RAISE EXCEPTION 'This function can only add AI test users to queue';
  END IF;

  -- Insert the AI user queue entry directly (bypasses RLS)
  INSERT INTO public.matchmaking_queue (
    id, user_id, elo_rating, queue_type, time_control, preferred_color,
    max_elo_difference, status, joined_at, expires_at, created_at, updated_at, is_deleted
  ) VALUES (
    queue_id, user_id, user_elo, queue_type, time_control, preferred_color,
    max_elo_difference, 'waiting', NOW(), NOW() + INTERVAL '10 minutes', NOW(), NOW(), false
  );

  RETURN queue_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to remove all AI users from matchmaking queue
CREATE OR REPLACE FUNCTION public.remove_ai_users_from_queue()
RETURNS INTEGER AS $$
DECLARE
  deleted_count INTEGER;
BEGIN
  -- Delete all queue entries for AI users
  DELETE FROM public.matchmaking_queue
  WHERE user_id IN (
    SELECT id FROM public.users WHERE email LIKE '%@aitest.com'
  );

  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  RETURN deleted_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permissions for queue functions
GRANT EXECUTE ON FUNCTION public.add_ai_user_to_queue TO authenticated;
GRANT EXECUTE ON FUNCTION public.remove_ai_users_from_queue TO authenticated;
