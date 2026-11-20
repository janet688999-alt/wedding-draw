-- 振明 & 珮君 Wedding Bingo — Supabase setup
-- Run this entire script once in Supabase Dashboard > SQL Editor.
-- It creates 70 assignable slots. The card numbers themselves are generated
-- deterministically by bingo.html from the returned slot number.

create table if not exists public.bingo_assignments (
  slot integer primary key check (slot between 1 and 70),
  visitor_token uuid not null unique,
  assigned_at timestamptz not null default now()
);

alter table public.bingo_assignments enable row level security;

-- Guests must not be able to read or write the assignment table directly.
revoke all on table public.bingo_assignments from anon, authenticated;

create or replace function public.assign_bingo_card(p_visitor_token uuid)
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare
  existing_slot integer;
  available_slot integer;
begin
  if p_visitor_token is null then
    raise exception 'A visitor token is required';
  end if;

  -- Serialize allocation so simultaneous scans cannot receive the same slot.
  perform pg_catalog.pg_advisory_xact_lock(20261119, 60060);

  select slot into existing_slot
  from public.bingo_assignments
  where visitor_token = p_visitor_token;

  if existing_slot is not null then
    return existing_slot;
  end if;

  select slots.slot_no
    into available_slot
  from generate_series(1, 70) as slots(slot_no)
  where not exists (
    select 1
    from public.bingo_assignments a
    where a.slot = slots.slot_no
  )
  order by slots.slot_no
  limit 1;

  if available_slot is null then
    raise exception 'All 70 Bingo cards have been assigned';
  end if;

  insert into public.bingo_assignments(slot, visitor_token)
  values (available_slot, p_visitor_token);

  return available_slot;
end;
$$;

-- Allow guests using the public anon key to call only this allocator function.
revoke all on function public.assign_bingo_card(uuid) from public;
grant execute on function public.assign_bingo_card(uuid) to anon, authenticated;

-- Optional organizer check (run manually in SQL Editor):
-- select count(*) as assigned_cards from public.bingo_assignments;
-- select slot, assigned_at from public.bingo_assignments order by slot;

-- Organizer reset ONLY after the event / when you intentionally want to restart:
-- delete from public.bingo_assignments;
