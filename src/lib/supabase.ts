import { createClient } from '@supabase/supabase-js';
const url = import.meta.env.VITE_SUPABASE_URL;
const anon = import.meta.env.VITE_SUPABASE_ANON_KEY;
export const supabase = url && anon ? createClient(url, anon) : null;
// A chave anon é pública por design; RLS é obrigatória. Nunca exponha service_role ou tokens Mercado Pago.