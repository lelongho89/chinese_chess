-- Add is_anonymous column to users table
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS is_anonymous BOOLEAN NOT NULL DEFAULT FALSE;

-- Update the handle_new_user function to include is_anonymous
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, display_name, is_anonymous, created_at, last_login_at)
  VALUES (
    NEW.id,
    COALESCE(NEW.email, ''),
    COALESCE(NEW.raw_user_meta_data->>'name', split_part(COALESCE(NEW.email, ''), '@', 1), 'Anonymous User'),
    COALESCE(NEW.is_anonymous, FALSE),
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    display_name = EXCLUDED.display_name,
    is_anonymous = EXCLUDED.is_anonymous,
    last_login_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Add policy for anonymous users to insert their own data
CREATE POLICY "Anonymous users can insert their own data" ON public.users
  FOR INSERT WITH CHECK (auth.uid() = id);
