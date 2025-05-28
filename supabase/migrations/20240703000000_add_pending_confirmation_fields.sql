-- Add new columns to matchmaking_queue table for pending confirmation workflow

ALTER TABLE public.matchmaking_queue
  ADD COLUMN IF NOT EXISTS confirmation_expires_at TIMESTAMPTZ NULL,
  ADD COLUMN IF NOT EXISTS player1_confirmed BOOLEAN NULL DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS player2_confirmed BOOLEAN NULL DEFAULT FALSE;

-- Update comments for the status column to include the new 'pendingConfirmation' state
COMMENT ON COLUMN public.matchmaking_queue.status IS 'Status of the queue entry: ''waiting'', ''pendingConfirmation'', ''matched'', ''cancelled'', ''expired''';

-- (Optional but good practice) Add comments for the new columns
COMMENT ON COLUMN public.matchmaking_queue.confirmation_expires_at IS 'Timestamp for when the pending confirmation for a match expires.';
COMMENT ON COLUMN public.matchmaking_queue.player1_confirmed IS 'Flag indicating if player 1 (usually the initiator or first found) has confirmed the match.';
COMMENT ON COLUMN public.matchmaking_queue.player2_confirmed IS 'Flag indicating if player 2 (the opponent) has confirmed the match.';

-- No change needed for time_increment as it's stored in the metadata JSONB field.
-- No ENUM type alteration needed as the status column is TEXT.
