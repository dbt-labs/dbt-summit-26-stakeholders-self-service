# What is red on purpose

For instructors and TAs, and for anyone revisiting this repo after the event.

`README.md` tells attendees "some tests fail on this dataset by design — your instructor will
say which." This is the page that says which, so a TA can tell a real problem from a planted
one in seconds.

## Source freshness

**Measured** against the workshop warehouse on 2026-09-17 with Fusion 2.0.4:
`dbt source freshness` exits non-zero with 6 errors and 10 warnings. `sources.json` is still
written, so Catalog populates correctly despite the non-zero exit.

| Source table | Tier | Result | Expected? |
|---|---|---|---|
| `RAW_ORDERS` | A | error — stale | Yes |
| `RAW_PAYMENTS` | A | error — stale | Yes |
| `RAW_BREW_EVENTS` | A | error — stale | Yes |
| `RAW_CUSTOMERS` | A | error — stale | Yes |
| `RAW_ORDER_ITEMS` | B | error — stale | Yes |
| `RAW_POTION_INGREDIENTS` | B | *was* `dbt9002` type error | **No — fixed.** `loaded_at_query` returned a date; it now casts to `timestamp_ntz`. Expect stale from here. |
| `RAW_GUILD_MEMBERSHIPS` | C | warn — stale | Yes |
| `RAW_INGREDIENTS` | C | warn — stale | Yes |
| `RAW_POTIONS` | C | warn — stale | Yes |
| `RAW_SHOPS` | C | warn — stale | Yes |
| `RAW_SUPPLIERS` | C | warn — stale | Yes |
| `RAW_GUILDS` | C | **pass** | Yes — its thresholds are 30d/90d, and the warehouse load was inside 30 days |

That run also confirmed something that could not be tested locally: **Tier C works**.
Warehouse-metadata freshness, with no `loaded_at_field` at all, returns real timestamps in
Fusion 2.0.4 — `RAW_GUILDS` passing is the proof, since a pass requires an actual measurement.

### No threshold can stay green on this dataset

Worth being blunt about, because it is the honest end of the argument in
[`DATA_LIMITATIONS.md`](DATA_LIMITATIONS.md).

The workshop warehouse loads `RAW` once and never touches it again. So the newest event time is
frozen *and* the warehouse's `last_altered` is frozen. Every check therefore drifts one way only:
pass → warn → error, as the calendar moves. `RAW_GUILDS` passes today and will warn, then error,
with no change to the data or the config.

A threshold that can never fire is useless; so is one that always fires. On a static fixture
there is no third option, so the choice is to keep the thresholds honest and write this page.
Do not "fix" a red freshness check here by widening the window — you would just be moving the
date at which it goes red again.

If a session needs green freshness for a demo, the only real fix is to make the data move:
re-load `RAW`, or have the provisioning job touch the tables so `last_altered` is recent. That
is an environment change, not a project change.

### Consequences for running the project

- `dbt source freshness` **will exit non-zero**. If it runs as its own job step, expect the job
  to be marked failed. That is the intended state of this branch.
- `dbt build` includes source freshness in Fusion, so a build on this branch hits the same
  errors. Use `--exclude-resource-type source` to get a clean model build.

## Data tests: seeded messiness

The generator plants realistic dirt. These are the tests expected to catch it:

| Test | Why it fails | What to tell an attendee |
|---|---|---|
| `not_null` on `dim_ingredients.supplier_id` / `stg_merlinco_ingredients.supplier_id` | Some ingredients reference suppliers absent from `RAW_SUPPLIERS` | This is the caveat documented on `dim_ingredients.supplier_name`. The test makes the documented problem visible instead of leaving it as prose. |
| `accepted_values` on `quality_check` | Some brew events have a blank quality check | Documented on `fct_brew_events.quality_check`. Blank falls out of both the pass and fail counts. |
| `not_null` on `is_regulated` / `is_hazardous` | Boolean normalization returns null for unrecognized input | Documented on both columns: empty means unknown, not false. |

**This list is unverified.** It was written from reading the models and the generator's seeded
messiness, not from a build against the workshop warehouse — there was no warehouse connection
available when this branch was built. Before the session, run the verification pass below and
correct this table from the actual output.

## A local `dbt parse` does not validate the semantic manifest

This is the most important line on this page, and it was learned the hard way.

Without platform configuration, dbt emits `InvalidConfig (dbt1005): Skipping semantic manifest
validation` and carries on. A locally clean parse therefore tells you **nothing** about whether
the semantic models and metrics are valid.

While this branch was being built, that warning was suppressed to get a zero-warning local
parse. It hid three real errors — duplicate dimension/primary-entity pairings, where
`fct_customer_lifetime_value` declared `signed_up_date`, `home_region` and `favored_discipline`
as dimensions on the `customer` entity that `dim_customers` already owned. Nothing local caught
it; a platform `dbt build` failed immediately with all three.

The fix and the rule that came out of it:

- A dimension may be paired with a given primary entity **once** across the project. The
  dimension model owns the descriptive dimensions; facts sharing that entity reach them through
  the join and must not redeclare them.
- `fct_customer_lifetime_value` now declares no `dimension:` block on those three columns, and
  its `agg_time_dimension` is `first_order_date` rather than `signed_up_date`.
- **Any change to a `semantic_model`, `entity`, `dimension` or `metric` block must be confirmed
  by a platform build before it is trusted.** CI here deliberately leaves the warning visible
  rather than suppressing it, as a standing reminder.

## Verification pass — run this before the session

Run this **in the platform**, not locally, so the semantic manifest is actually validated:

```bash
dbt build 2>&1 | tee /tmp/merlinco-build.log
dbt source freshness 2>&1 | tee /tmp/merlinco-freshness.log
```

Then check four things and update this page:

1. **Which data tests failed.** Correct the table above. Any failure not listed there is a real
   problem, not a planted one.
2. **Whether any contract failed on a `data_type` mismatch.** The aggregate-derived numerics are
   the likely ones — see the contract section of
   [`DATA_LIMITATIONS.md`](DATA_LIMITATIONS.md). The error names the actual type, so each one is
   a one-line fix.
3. **Whether the new `not_null` tests on foreign keys pass.** This branch added `not_null`
   alongside every `relationships` test, because a relationships test passes on a null. If any
   of them fail on real data, that is a finding to document on the column — not a test to
   delete.
4. **Whether the semantic manifest validates.** Twelve semantic models, twenty-four metrics.
   The duplicate-pairing class of error is fixed and audited project-wide, but this is the only
   place it can be checked.

## What should be green

Everything else. All eleven unit tests, every `unique` test, every `relationships` test, and
all eight singular tests. If any of those are red, something is genuinely wrong.

The two membership unit tests are worth a note: their fixtures are generated relative to run
time rather than hard-coded, precisely so they don't rot. They used to carry literal 2025 and
2027 dates, which would have started failing on their own in 2027 on a repo that stays public.
