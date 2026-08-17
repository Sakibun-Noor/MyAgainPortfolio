/* ─────────────────────────────────────────────────────────────────
   Supabase connection — used by index.html (read) and admin.html (write).

   Paste your two values below. Both are safe to keep in this public file:
   the anon key only grants what your Row Level Security policies allow,
   which is read-only for visitors and write access for a signed-in admin.

   Find them in Supabase → Project Settings → API:
     url  = "Project URL"
     anon = "anon public" key

   NEVER put the "service_role" key in this file. It bypasses all
   security policies and would give anyone full access to your database.
   ───────────────────────────────────────────────────────────────── */
window.SB = {
  url:  'YOUR_PROJECT_URL',
  anon: 'YOUR_ANON_KEY'
};
