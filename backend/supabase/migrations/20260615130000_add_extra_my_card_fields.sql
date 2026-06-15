-- Add extra customization columns to my_cards table
ALTER TABLE public.my_cards 
ADD COLUMN IF NOT EXISTS card_ratio TEXT DEFAULT 'standard',
ADD COLUMN IF NOT EXISTS show_icons BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS photo_size DOUBLE PRECISION DEFAULT 56.0,
ADD COLUMN IF NOT EXISTS text_sizes JSONB DEFAULT '{}'::jsonb;
