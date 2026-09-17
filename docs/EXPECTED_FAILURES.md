# What is red on purpose

For instructors and TAs, and for anyone revisiting this repo after the event.

`README.md` tells attendees "some tests fail on this dataset by design — your instructor will
say which." This is the page that says which, so a TA can tell a real problem from a planted
one in seconds.

## Source freshness: every table, always

`dbt source freshness` fails on all twelve source tables. The dataset is static, so the newest
event is fixed in time and every Tier A and Tier B threshold is already blown. Tier C tables
depend on when the workshop warehouse last loaded them, so they may pass or fail depending on
setup timing.

This is the intended experience. See [`DATA_LIMITATIONS.md`](DATA_LIMITATIONS.md) for why
loosening the thresholds would be the wrong fix. If an attendee's build is blocked by it, the
flag is `--exclude-resource-type source`.

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

## Verification pass — run this before the session

```bash
export DBT_ENGINE_NO_WARN_SEMANTIC_MANIFEST_VALIDATION=1
dbt build 2>&1 | tee /tmp/merlinco-build.log
dbt source freshness 2>&1 | tee /tmp/merlinco-freshness.log
```

Then check three things and update this page:

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

## What should be green

Everything else. All eleven unit tests, every `unique` test, every `relationships` test, and
all eight singular tests. If any of those are red, something is genuinely wrong.

The two membership unit tests are worth a note: their fixtures are generated relative to run
time rather than hard-coded, precisely so they don't rot. They used to carry literal 2025 and
2027 dates, which would have started failing on their own in 2027 on a repo that stays public.
