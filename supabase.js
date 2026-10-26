import 'react-native-url-polyfill/auto';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { createClient } from '@supabase/supabase-js';

// These are the project's public client credentials. Never put a service_role/secret key here.
const SUPABASE_URL = 'https://onrpmtqycimrnhjejjkd.supabase.co';
const SUPABASE_PUBLISHABLE_KEY = 'sb_publishable_iCXFgf4lessNv7hBuS8qlA_JGHBGlgj';

export const supabase = createClient(SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY, {
  auth: {
    storage: AsyncStorage,
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: false,
  },
});
