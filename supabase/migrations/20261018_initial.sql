-- Schema inicial; execute no SQL Editor do seu projeto Supabase após revisão.
create extension if not exists pgcrypto;
create table if not exists public.stores (
 id uuid primary key default gen_random_uuid(),
 owner_id uuid not null references auth.users(id) on delete cascade,
 name text not null default 'Minha Loja',
 created_at timestamptz not null default now()
);
create table if not exists public.products (
 id uuid primary key default gen_random_uuid(),
 store_id uuid not null references public.stores(id) on delete cascade,
 name text not null,
 slug text not null,
 description text not null default '',
 source_url text,
 price_cents integer not null check (price_cents >= 0),
 compare_price_cents integer check (compare_price_cents is null or compare_price_cents >= 0),
 image_url text,
 images jsonb not null default '[]'::jsonb,
 benefits jsonb not null default '[]'::jsonb,
 faq jsonb not null default '[]'::jsonb,
 theme_color text not null default '#6757e8',
 published boolean not null default false,
 created_at timestamptz not null default now(),
 unique(store_id, slug)
);
create table if not exists public.orders (
 id uuid primary key default gen_random_uuid(),
 store_id uuid not null references public.stores(id) on delete cascade,
 product_id uuid not null references public.products(id),
 quantity integer not null check(quantity > 0),
 total_cents integer not null check(total_cents >= 0),
 status text not null default 'pending' check(status in ('pending','approved','rejected','cancelled','refunded')),
 provider_payment_id text unique,
 buyer_email text,
 created_at timestamptz not null default now()
);
alter table public.stores enable row level security;
alter table public.products enable row level security;
alter table public.orders enable row level security;
create policy "store owner access" on public.stores for all to authenticated using (owner_id = auth.uid()) with check(owner_id = auth.uid());
create policy "product owner access" on public.products for all to authenticated using (exists(select 1 from public.stores s where s.id = store_id and s.owner_id=auth.uid())) with check(exists(select 1 from public.stores s where s.id = store_id and s.owner_id=auth.uid()));
create policy "public can read published product" on public.products for select to anon using(published = true);
create policy "order owner read" on public.orders for select to authenticated using(exists(select 1 from public.stores s where s.id=store_id and s.owner_id=auth.uid()));
-- Pedidos e pagamentos devem ser criados/atualizados por funções backend autenticadas, nunca pelo navegador.
