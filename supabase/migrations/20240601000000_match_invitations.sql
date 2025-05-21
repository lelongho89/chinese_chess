-- Create match_invitations table
CREATE TABLE IF NOT EXISTS public.match_invitations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  creator_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  recipient_id UUID REFERENCES public.users(id),
  status INTEGER NOT NULL DEFAULT 0, -- 0: pending, 1: accepted, 2: rejected, 3: expired
  invitation_code TEXT NOT NULL,
  expiration_time TIMESTAMP WITH TIME ZONE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
  metadata JSONB
);

-- Enable RLS for match_invitations
ALTER TABLE public.match_invitations ENABLE ROW LEVEL SECURITY;

-- Match invitations policies
CREATE POLICY "Users can read their own invitations (created or received)" ON public.match_invitations
  FOR SELECT USING (auth.uid() = creator_id OR auth.uid() = recipient_id OR recipient_id IS NULL);

CREATE POLICY "Users can create invitations" ON public.match_invitations
  FOR INSERT WITH CHECK (auth.uid() = creator_id);

CREATE POLICY "Users can update their own invitations" ON public.match_invitations
  FOR UPDATE USING (auth.uid() = creator_id OR auth.uid() = recipient_id);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS match_invitations_creator_id_idx ON public.match_invitations(creator_id);
CREATE INDEX IF NOT EXISTS match_invitations_recipient_id_idx ON public.match_invitations(recipient_id);
CREATE INDEX IF NOT EXISTS match_invitations_invitation_code_idx ON public.match_invitations(invitation_code);
