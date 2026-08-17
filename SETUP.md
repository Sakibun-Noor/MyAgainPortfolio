# Setup

The site works right now with no backend — everything you see is written into
`index.html` as defaults. You only need the steps below to make the admin
dashboard work, so you can add reels and edit text without touching code.

Budget about ten minutes, once.

---

## 1. Create a Supabase project

Sign up at [supabase.com](https://supabase.com) and create a project. The free
tier is enough: 500 MB database, 1 GB file storage, 5 GB bandwidth a month.

Pick a region near you or near your visitors. Save the database password it
gives you somewhere safe, though you will not need it for this.

## 2. Run the schema

In the Supabase sidebar open **SQL Editor → New query**. Paste in the entire
contents of [`schema.sql`](schema.sql) and press **Run**.

That creates the `content` table, the `media` storage bucket, and the security
rules that let visitors read your site but only you write to it. It is safe to
run more than once.

## 3. Create your login

Go to **Authentication → Users → Add user**. Enter your email and a password,
and tick *Auto Confirm User* so you can sign in immediately.

This is the login you will use for the dashboard. It is separate from your
Supabase account login.

## 4. Turn off public sign-ups

Go to **Authentication → Sign In / Providers** and switch **off** "Allow new
users to sign up".

Do not skip this. The write rules trust any signed-in user, so if strangers can
register they can edit your site. If you would rather not depend on that switch,
the last section of `schema.sql` has a block you can uncomment to pin write
access to your email address specifically.

## 5. Paste your keys

Go to **Project Settings → API** and copy two values into
[`config.js`](config.js):

```js
window.SB = {
  url:  'https://xxxxxxxxxxxx.supabase.co',   // Project URL
  anon: 'eyJhbGciOi...'                        // anon public key
};
```

Both are fine to commit — the anon key only grants what the rules in step 2
allow. **Never put the `service_role` key in this file.** It bypasses every
security rule.

Commit and push, and Vercel will pick it up.

---

## Using the dashboard

Open `/admin.html` on your site and sign in with the account from step 3.

The first time, the forms are pre-filled with whatever the site currently
shows, so you are editing rather than starting from nothing. Press **Save
changes** on a section and it goes to the database. Refresh the site to see it.

Each section saves on its own. A dot next to a tab means you have unsaved
changes there.

### Adding a reel

**Reels → Add reel.** Then either:

- **Upload a video file** — pick an MP4 or WebM. A cover image is captured from
  the video automatically, so you usually do not need to add one.
- **Link to an existing post** — paste the normal share link from Instagram,
  YouTube Shorts, TikTok, Vimeo or Facebook. These cost you no storage and no
  bandwidth, so prefer them for anything you have already posted. You do need
  to add a cover image yourself, because those sites do not hand out thumbnails.

Reels are portrait, 9:16. Covers look best at 1080×1920.

Keep uploads under 50 MB — that is the free tier's per-file limit. A 30-second
reel at 1080p is usually 8–15 MB. If a file is too big:

```bash
ffmpeg -i input.mp4 -vf "scale=1080:-2" -c:v libx264 -crf 28 -c:a aac -b:a 96k output.mp4
```

### Deleting things

Deleting a reel or project removes it from the page but leaves the uploaded file
in storage. Clear those out under **Media** when you want the space back.

---

## If something goes wrong

**Dashboard shows "Almost there"** — `config.js` still has the placeholder
values, or the file did not deploy.

**"Could not load content"** — `schema.sql` has not been run, or it failed part
way. Re-run it; it is safe.

**Sign-in rejected** — the user does not exist yet. Check **Authentication →
Users**.

**Saves fail with a permissions error** — you are signed in, but the write
policy is rejecting you. If you uncommented the email-locked block in
`schema.sql`, check the address in it matches your login exactly.

**The site ignores your edits** — the site reads from the database on load and
falls back to its built-in defaults if the request fails. Open the browser
console on `index.html` and check the request to `/rest/v1/content` returns 200.

---

## Local preview

```bash
python -m http.server 8899
```

Then open `http://localhost:8899`. It is a static site, so any file server
works — but opening `index.html` directly as a `file://` URL will not, because
the content fetch needs a real origin.
