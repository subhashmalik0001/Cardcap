-- Create storage bucket for card images if not exists
INSERT INTO storage.buckets (id, name, public)
VALUES ('card-images', 'card-images', true)
ON CONFLICT (id) DO NOTHING;

-- Drop policies if they exist to prevent duplication errors
DROP POLICY IF EXISTS "Users can upload own card images" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can read card images" ON storage.objects;

-- Allow authenticated users to upload their own card images
CREATE POLICY "Users can upload own card images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'card-images' AND
  (storage.foldername(name))[1] = 'cards' AND
  (storage.foldername(name))[2] = auth.uid()::text
);

-- Allow authenticated users to read all card images
CREATE POLICY "Authenticated users can read card images"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'card-images');

-- Add card_image_url column to business_cards table
ALTER TABLE public.business_cards 
ADD COLUMN IF NOT EXISTS card_image_url TEXT;

-- Add scan_method column to track how card was scanned
ALTER TABLE public.business_cards
ADD COLUMN IF NOT EXISTS scan_method TEXT DEFAULT 'auto';
