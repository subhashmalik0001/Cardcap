-- Add source column to business_cards table (to track import method: scan, qr, manual)
ALTER TABLE public.business_cards 
ADD COLUMN IF NOT EXISTS source TEXT DEFAULT 'scan';

-- Add qr_generated_at column to profiles table (to track when user generated their card QR)
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS qr_generated_at TIMESTAMPTZ;
