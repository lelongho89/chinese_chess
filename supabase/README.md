# Supabase Setup for Chinese Chess

This directory contains the Supabase migration scripts for setting up the database schema for the Chinese Chess application.

## Getting Started

1. Create a Supabase project at [https://supabase.com](https://supabase.com)
2. Get your Supabase URL and anon key from the project settings
3. Update the `.env` file in the root directory with your Supabase URL and anon key

## Database Schema

The database schema includes the following tables:

- `users`: Stores user profile data and game statistics
- `friends`: Stores user friendships
- `games`: Stores game data
- `tournaments`: Stores tournament data
- `tournament_participants`: Stores tournament participants
- `matches`: Stores tournament matches

## Authentication

The application uses Supabase Authentication for user registration and login. The authentication system supports:

1. Email/password registration and login
2. Google sign-in
3. Facebook sign-in
4. Password reset

## Row Level Security (RLS)

The database uses Row Level Security (RLS) to ensure that users can only access data they are authorized to access. The RLS policies are defined in the migration scripts.

## Applying Migrations

To apply the migrations to your Supabase project, you can use the Supabase CLI:

```bash
# Install Supabase CLI
npm install -g supabase

# Login to Supabase
supabase login

# Link to your Supabase project
supabase link --project-ref <your-project-ref>

# Apply migrations
supabase db push
```

Alternatively, you can copy the SQL from the migration files and run it in the Supabase SQL editor.

## Setting Up OAuth Providers

To set up OAuth providers (Google, Facebook), follow these steps:

1. Go to your Supabase project settings
2. Navigate to Authentication > Providers
3. Enable and configure the providers you want to use
4. Update your app's OAuth redirect URLs

## Realtime

The application uses Supabase Realtime for real-time updates. To enable Realtime for your tables:

1. Go to your Supabase project settings
2. Navigate to Database > Replication
3. Enable replication for the tables you want to use with Realtime
