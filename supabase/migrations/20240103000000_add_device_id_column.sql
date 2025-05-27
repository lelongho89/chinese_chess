-- Add device_id column to users table for anonymous user device tracking
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS device_id TEXT;

-- Create index on device_id for faster lookups
CREATE INDEX IF NOT EXISTS idx_users_device_id ON public.users(device_id);

-- Create index on device_id + is_anonymous for anonymous user lookups
CREATE INDEX IF NOT EXISTS idx_users_device_id_anonymous ON public.users(device_id, is_anonymous) WHERE is_anonymous = true;

-- Update the handle_new_user function to include device_id
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, display_name, is_anonymous, device_id, created_at, last_login_at)
  VALUES (
    NEW.id,
    COALESCE(NEW.email, ''),
    COALESCE(NEW.raw_user_meta_data->>'name', split_part(COALESCE(NEW.email, ''), '@', 1), 'Anonymous User'),
    COALESCE(NEW.is_anonymous, FALSE),
    NEW.raw_user_meta_data->>'device_id',
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    display_name = EXCLUDED.display_name,
    is_anonymous = EXCLUDED.is_anonymous,
    device_id = EXCLUDED.device_id,
    last_login_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Add RLS policy for device-based access for anonymous users
CREATE POLICY "Anonymous users can access their own data via device_id" ON public.users
  FOR ALL USING (
    (auth.uid() = id) OR 
    (is_anonymous = true AND device_id IS NOT NULL AND device_id = current_setting('app.current_device_id', true))
  );

-- Function to set device_id context for anonymous users
CREATE OR REPLACE FUNCTION public.set_device_id_context(device_id_param TEXT)
RETURNS void AS $$
BEGIN
  PERFORM set_config('app.current_device_id', device_id_param, true);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission on the function
GRANT EXECUTE ON FUNCTION public.set_device_id_context(TEXT) TO authenticated, anon;
