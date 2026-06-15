-- Create My Cards table
CREATE TABLE IF NOT EXISTS public.my_cards (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  details JSONB NOT NULL,
  template_id TEXT NOT NULL,
  field_positions JSONB NOT NULL,
  photo_shape TEXT NOT NULL,
  photo_url TEXT,
  text_color TEXT NOT NULL,
  visible_fields JSONB NOT NULL,
  card_image_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.my_cards ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='my_cards' AND policyname='Users can manage own personal card') THEN
    CREATE POLICY "Users can manage own personal card" ON public.my_cards FOR ALL USING (auth.uid() = user_id);
  END IF;
END $$;

-- Create update trigger
DROP TRIGGER IF EXISTS set_updated_at_my_cards ON public.my_cards;
CREATE TRIGGER set_updated_at_my_cards
  BEFORE UPDATE ON public.my_cards
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
