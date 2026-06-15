-- Profiles table (extends Supabase auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  full_name TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Business cards table
CREATE TABLE IF NOT EXISTS public.business_cards (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT,
  designation TEXT,
  company TEXT,
  email TEXT,
  phones JSONB DEFAULT '[]'::jsonb,
  website TEXT,
  address TEXT,
  linkedin TEXT,
  twitter TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_business_cards_user_id ON public.business_cards(user_id);
CREATE INDEX IF NOT EXISTS idx_business_cards_created_at ON public.business_cards(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_business_cards_name ON public.business_cards USING gin(to_tsvector('english', COALESCE(name, '')));
CREATE INDEX IF NOT EXISTS idx_business_cards_company ON public.business_cards USING gin(to_tsvector('english', COALESCE(company, '')));

-- Row Level Security (even though server uses service role, good practice)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.business_cards ENABLE ROW LEVEL SECURITY;

-- RLS Policies
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='profiles' AND policyname='Users can view own profile') THEN
    CREATE POLICY "Users can view own profile" ON public.profiles FOR SELECT USING (auth.uid() = id);
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='profiles' AND policyname='Users can update own profile') THEN
    CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='business_cards' AND policyname='Users can manage own cards') THEN
    CREATE POLICY "Users can manage own cards" ON public.business_cards FOR ALL USING (auth.uid() = user_id);
  END IF;
END $$;

-- Auto-update updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_updated_at_profiles ON public.profiles;
CREATE TRIGGER set_updated_at_profiles
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS set_updated_at_cards ON public.business_cards;
CREATE TRIGGER set_updated_at_cards
  BEFORE UPDATE ON public.business_cards
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Personal business card design table
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

-- RLS
ALTER TABLE public.my_cards ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='my_cards' AND policyname='Users can manage own personal card') THEN
    CREATE POLICY "Users can manage own personal card" ON public.my_cards FOR ALL USING (auth.uid() = user_id);
  END IF;
END $$;

DROP TRIGGER IF EXISTS set_updated_at_my_cards ON public.my_cards;
CREATE TRIGGER set_updated_at_my_cards
  BEFORE UPDATE ON public.my_cards
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
