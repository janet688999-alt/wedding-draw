# 振明 & 珮君 Wedding Bingo — Supabase edition

## Files
- `bingo.html` — guest page; one shared URL automatically assigns a unique card.
- `supabase-setup.sql` — database setup; run once in Supabase SQL Editor.
- `bingo-qr-code.html` — printable single shared QR code.

## Setup
1. Create a Supabase project at https://supabase.com/.
2. In the Supabase dashboard, open **SQL Editor**, create a new query, paste all of `supabase-setup.sql`, and run it.
3. Open **Project Settings → API** (or **Connect**) and copy:
   - Project URL
   - Public anon key / publishable key
4. In `bingo.html`, replace:
   - `YOUR_SUPABASE_PROJECT_URL`
   - `YOUR_SUPABASE_ANON_OR_PUBLISHABLE_KEY`
   with those values. The public anon/publishable key is intended for browser use; **never put a service_role or secret key in this file**.
5. Upload/replace `bingo.html` in the existing GitHub Pages repository at the same path:
   `https://janet688999-alt.github.io/wedding-draw/bingo.html`
6. Open that URL on a phone and test. Then open it in a second browser/private window and confirm it receives a different card. Refresh the first browser and confirm it keeps its original card.
7. Open `bingo-qr-code.html` locally, print it, and display that single QR code to all guests.

## How assignment works
- Supabase stores one row for each claimed slot (1–70).
- A database transaction-level advisory lock serializes allocation requests.
- The same browser token receives the same slot on refresh.
- When all 70 slots are allocated, the page displays an all-cards-assigned error.
- Card contents are generated in the browser from the assigned slot using the original deterministic number-card algorithm.

## Important limitations / event operations
- The browser token is stored in localStorage. Clearing site data or switching devices creates a new token and may allocate another card. This is anonymous convenience, not identity verification.
- Keep the Supabase project active and the deployed site URL unchanged through the event.
- Do not run the SQL reset statement during the event. Resetting assignments can cause duplicate cards.
- If testing with real scans, test assignments consume slots. Before the event, you can reset test data in SQL Editor with:
  `delete from public.bingo_assignments;`
  Only do this before guests start using it.
- You can check usage in SQL Editor:
  `select count(*) from public.bingo_assignments;`
