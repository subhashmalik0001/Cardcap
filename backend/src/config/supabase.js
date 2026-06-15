const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = process.env.SUPABASE_URL;

const anonClient = createClient(supabaseUrl, process.env.SUPABASE_ANON_KEY);

const adminClient = createClient(supabaseUrl, process.env.SUPABASE_SERVICE_ROLE_KEY, {
  auth: {
    autoRefreshToken: false,
    persistSession: false,
  },
});

module.exports = { anonClient, adminClient };
