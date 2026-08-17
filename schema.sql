-- ═══════════════════════════════════════════════════════════════════
--  Portfolio backend setup
--  Run once in Supabase → SQL Editor → New query → Run.
--  Safe to re-run; every statement is idempotent.
-- ═══════════════════════════════════════════════════════════════════

-- ── 1. Content table ──────────────────────────────────────────────
-- One row per section. `value` holds that section's JSON exactly as
-- index.html expects it, so adding a field never needs a migration.
create table if not exists public.content (
  key        text primary key,
  value      jsonb not null,
  updated_at timestamptz not null default now()
);

alter table public.content enable row level security;

-- Visitors may read. Only a signed-in admin may write.
drop policy if exists content_public_read on public.content;
create policy content_public_read
  on public.content for select
  to anon, authenticated
  using (true);

drop policy if exists content_admin_write on public.content;
create policy content_admin_write
  on public.content for all
  to authenticated
  using (true)
  with check (true);

-- ── 2. Media bucket ───────────────────────────────────────────────
-- Public so <video> and <img> can load without signed URLs.
insert into storage.buckets (id, name, public)
values ('media', 'media', true)
on conflict (id) do update set public = true;

drop policy if exists media_public_read on storage.objects;
create policy media_public_read
  on storage.objects for select
  to anon, authenticated
  using (bucket_id = 'media');

drop policy if exists media_admin_insert on storage.objects;
create policy media_admin_insert
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'media');

drop policy if exists media_admin_update on storage.objects;
create policy media_admin_update
  on storage.objects for update
  to authenticated
  using (bucket_id = 'media');

drop policy if exists media_admin_delete on storage.objects;
create policy media_admin_delete
  on storage.objects for delete
  to authenticated
  using (bucket_id = 'media');

-- ── 3. Lock writes to your account only (recommended) ─────────────
-- The policies above trust ANY signed-in user. That is only safe while
-- public sign-ups are disabled. Replace the email below with your own
-- and run this section to pin write access to a single account, so an
-- accidentally-enabled sign-up form cannot hand anyone your site.
--
-- Uncomment the block, set the address, and run it.

-- create or replace function public.is_site_admin() returns boolean
-- language sql stable as $$
--   select coalesce(auth.jwt() ->> 'email', '') = 'you@example.com';
-- $$;
--
-- drop policy if exists content_admin_write on public.content;
-- create policy content_admin_write on public.content for all
--   to authenticated using (public.is_site_admin())
--   with check (public.is_site_admin());
--
-- drop policy if exists media_admin_insert on storage.objects;
-- create policy media_admin_insert on storage.objects for insert
--   to authenticated with check (bucket_id = 'media' and public.is_site_admin());
--
-- drop policy if exists media_admin_update on storage.objects;
-- create policy media_admin_update on storage.objects for update
--   to authenticated using (bucket_id = 'media' and public.is_site_admin());
--
-- drop policy if exists media_admin_delete on storage.objects;
-- create policy media_admin_delete on storage.objects for delete
--   to authenticated using (bucket_id = 'media' and public.is_site_admin());

-- ═══════════════════════════════════════════════════════════════════
--  Remaining setup, done in the dashboard rather than SQL:
--
--  1. Authentication → Users → "Add user" → create your own admin
--     account with an email and password. This is the login you will
--     use at /admin.html. Do not enable public sign-ups.
--
--  2. Authentication → Sign In / Providers → turn OFF "Allow new users
--     to sign up". Without this, anyone could register and then edit
--     your site, because the write policy above trusts any signed-in
--     user and you are meant to be the only one.
--
--  3. Paste your Project URL and anon key into config.js.
-- ═══════════════════════════════════════════════════════════════════
