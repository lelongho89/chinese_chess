# Database Fix for Anonymous User Creation

## Problem
The app is getting an `AuthRetryableFetchException: Database error creating anonymous user` because the database schema is missing the `is_anonymous` column.

## Solution

### Option 1: Apply Database Migration (Recommended)
1. Go to your Supabase project dashboard
2. Navigate to the SQL Editor
3. Run the following SQL script:

```sql
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
```

### Option 2: Temporary Workaround (Already Implemented)
The code has been updated to handle database schema issues gracefully:

1. **Graceful error handling**: Anonymous login will work even if database creation fails
2. **Minimal data fallback**: If full user creation fails, it tries with minimal required data
3. **Conditional field inclusion**: The `is_anonymous` field is only included if needed

## What Was Changed

### 1. SupabaseAuthService
- Added try-catch around `createAnonymousUser` call
- Anonymous login continues even if database creation fails
- Users can still use the app without database storage

### 2. UserModel
- Modified `toMap()` to conditionally include `is_anonymous` field
- Prevents database errors when column doesn't exist

### 3. UserRepository
- Added fallback mechanism for database creation
- Tries full user creation first, then minimal data if that fails
- Better error logging and handling

## Testing
After applying the database migration or with the workaround:

1. Try "Continue as Guest" on the login screen
2. The app should successfully create an anonymous user
3. Check the Supabase dashboard to verify user creation

## Migration File
The migration file is available at: `supabase/migrations/20240102000000_add_is_anonymous_column.sql`
