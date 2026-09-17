# What is red on purpose

For instructors and TAs, and for anyone revisiting this repo after the event.

`README.md` tells attendees "some tests fail on this dataset by design — your instructor will
say which." This is the page that says which, so a TA can tell a real problem from a planted
one in seconds.

## Source freshness

**Measured** against the workshop warehouse with Fusion 2.0.4, over three runs on 2026-09-17.
`dbt source freshness` exits non-zero. `sources.json` is still written, so Catalog populates
correctly despite the failure.

Expected on the current config: **5 errors, 11 warnings.**

| Source table | Tier | Result | Why |
|---|---|---|---|
| `RAW_ORDERS` | A | error — stale | Static dataset. By design. |
| `RAW_PAYMENTS` | A | error — stale | Static dataset. By design. |
| `RAW_BREW_EVENTS` | A | error — stale | Static dataset. By design. |
| `RAW_CUSTOMERS` | A | error — stale | Static dataset. By design. |
| `RAW_ORDER_ITEMS` | B | error — stale | Borrows `RAW_ORDERS`' event clock, which is frozen. By design. |
| `RAW_GUILDS` | C | **pass** | 30d/90d window, and the warehouse load is inside it. Will warn, then error, as the calendar moves. |
| `RAW_GUILD_MEMBERSHIPS` | C | warn — stale | Past 7d, inside 30d. |
| `RAW_INGREDIENTS` | C | warn — stale | Past 7d, inside 30d. |
| `RAW_POTIONS` | C | warn — stale | Past 7d, inside 30d. |
| `RAW_SHOPS` | C | warn — stale | Past 7d, inside 30d. |
| `RAW_SUPPLIERS` | C | warn — stale | Past 7d, inside 30d. |
| `RAW_POTION_INGREDIENTS` | C | warn — stale | Past 7d, inside 30d. |

Plus **5 warnings of `dbt9002: timestamp type without a timezone, we will assume a UTC
timezone`** — one per `try_to_timestamp_ntz` expression, so four Tier A fields and one Tier B
query. Note the platform log truncates, so a run typically shows only one of these; all five are
there.

**Do not try to clear those five.** The behaviour they describe is the behaviour we want. The
raw text carries no UTC offset, so there is nothing to read; dbt assuming UTC is deterministic.
Casting to `timestamp_tz` instead would attach the *session* timezone, and identical data would
then report different freshness in different environments. Chasing them buys nothing anyway —
the command still exits non-zero on the five stale errors.

### Two bugs this exercise caught

Both were mine, and both are fixed. Recorded because they are the kind of thing only a real run
finds:

1. **`RAW_POTION_INGREDIENTS` `loaded_at_query` returned a date.** Fusion rejected it with
   `dbt9002: should have a timestamp type, but got Date32`. `loaded_at_query` must return a
   timestamp.
2. **`RAW_POTION_INGREDIENTS` was the wrong tier.** It borrowed `RAW_POTIONS`' `INTRODUCED_AT`
   as an event clock — but that is when a potion was *launched*, which is historical and says
   nothing about when recipe rows arrived. The result was the child erroring on an event clock
   while its own parent, measured by warehouse metadata, only warned: same data, two verdicts.
   It is now Tier C like the catalog it belongs to, which is why the error count dropped from 6
   to 5.

### What the run proved that local parsing could not

**Tier C works.** Warehouse-metadata freshness, with no `loaded_at_field` and no timestamp column
of any kind, returns real timestamps on Fusion 2.0.4. `RAW_GUILDS` passing is the proof — a pass
requires an actual measurement, not a skipped check. That matters because Tier C is the only
option available for `RAW_INGREDIENTS`, which has no date column at all.

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

## Data tests: nothing fails

**Measured** with `dbt build --exclude-resource-type source` against the workshop warehouse on
Fusion 2.0.4:

| What | Result |
|---|---|
| Data tests (160) | **all pass** |
| Unit tests (11) | **all pass**, including the two with run-relative membership fixtures |
| Enforced contracts (9) | **all pass** |
| Models | all build |

Two things that were flagged as risks are now closed:

- **The inferred contract `data_type` values were all correct**, including every
  aggregate-derived numeric — `lifetime_order_item_count` as `number(38,0)`,
  `days_to_first_order` and `days_since_last_order` as `number(9,0)`, and the `*_count` columns
  as `number(18,0)`. Those were read off the casts rather than measured, and the warehouse agreed
  with all of them.
- **The ~20 `not_null` tests added alongside existing `relationships` tests all pass.** There are
  no orphan or null foreign keys anywhere in this dataset.

So on this branch the only red signal is source freshness. `README.md` warns attendees that
"some tests fail on this dataset by design" — on `main` that refers to the freshness check Lab 2
adds. It is not true of data tests here.

## Correction: the seeded messiness is absorbed, not surfaced

An earlier version of this page listed three expected data-test failures — null
`supplier_id`, blank `quality_check`, null `is_regulated` / `is_hazardous`. **That was
speculation and it was wrong.** It had been written from reading the generator's mixed-format
input and the normalizer macros, not from a build. A real run passed all of them.

The mistake worth learning from is not the table; it is that the same speculation had been
written into *stakeholder-facing caveats*, which is precisely the failure
[`STAKEHOLDER_DOC_PATTERNS.md`](STAKEHOLDER_DOC_PATTERNS.md) warns about: "a plausible but false
warning is worse than no warning — it's the same wrong-but-believable failure this lesson exists
to prevent, just authored by you."

Three caveats were provably false and are corrected:

| Claim | Disproved by |
|---|---|
| `dim_potions.is_regulated` "can be empty" | `not_null` on `stg_merlinco_potions.is_regulated` passes |
| `dim_ingredients.is_hazardous` "can be empty" | `not_null` on `stg_merlinco_ingredients.is_hazardous` passes |
| `dim_ingredients.supplier_name` "can be empty when an ingredient points at a supplier not on record" | `not_null` *and* `relationships` on `stg_merlinco_ingredients.supplier_id` both pass |

The normalizer macros do absorb genuinely mixed input — `merlinco_normalize_boolean` maps `Y`,
`yes`, `TRUE`, `1`, `no`, `FALSE`, `0`; `merlinco_normalize_region` maps both codes and
case variants. The unit tests prove the *logic* handles unrecognizable input by returning null.
No unrecognizable input actually reaches it in this dataset. Those are different claims, and
only the first is true.

## Four open questions, answered by the next run

Four caveats could not be settled by any existing test, because `accepted_values` does not catch
an empty value — `NULL NOT IN (...)` is not true, so nulls pass silently. Rather than leave them
as prose assertions, each now has a `not_null` test at **warn** severity:

| Test | Settles |
|---|---|
| `not_null_stg_merlinco_brew_events_quality_check` | Are any quality checks unrecorded? |
| `not_null_stg_merlinco_shops_opened_at` | Does any shop have an unparseable opening date? |
| `not_null_stg_merlinco_customers_birth_year` | Any unparseable birth years? |
| `not_null_stg_merlinco_guilds_founded_year` | Any unparseable founding years? |

Warn rather than error, deliberately: an unrecorded quality check is a business condition worth
surfacing, not a reason to stop a build, and these exist to answer a question rather than to
enforce a rule.

**On the next `dbt build`, act on the result:** a warning means the caveat is real and should be
restored to plain language in the doc block; silence means the caveat should be deleted rather
than left as a hypothetical. Either way the prose stops guessing.

## Job setup: Catalog needs column schemas written explicitly

If Catalog shows a data product with **Columns 0** despite the YAML documenting every column,
the project is not the problem — the job is not producing column schemas.

`dbt compile --write-index` says so directly:

```
[warning] [Generic (dbt1000)]: --write-index: column schemas will not be populated
without `--static-analysis strict`; add `--write-lineage` to also write column-level lineage.
```

So the index is written, `dbt.node_columns` exists, and it has no column schemas in it. The
column panel in Catalog has nothing to show.

The step a job needs:

```bash
dbt compile --write-index --write-lineage --static-analysis strict
```

- `--static-analysis strict` is what populates column schemas. It needs a live warehouse
  connection, so it cannot run in the parse-only CI in this repo.
- `--write-lineage` additionally writes **column-level** lineage. Worth adding rather than
  leaving off: "which report breaks if I rename this column" is a far better answer than the
  model-level version, and lineage is a talking point in Lesson 3.

Two things to know before adding it:

- Strict static analysis does more work than a normal parse and can surface errors a lenient run
  does not. That is a feature, but budget for a first run that finds something.
- `dbt build` and `dbt source freshness` do not write the index. Catalog completeness is a
  separate job step from building and testing, which is why a fully green build can still leave
  Catalog looking empty.

If only *some* models show zero columns rather than all of them, this is not the cause — say so
and look at whether those models built in that environment at all.

### Secondary suspect: the commented-out `dbt-cloud` block

`dbt_project.yml` carries a commented `dbt-cloud:` block whose own note says it "enables Catalog
(beta) platform enrichment". It is left commented because this repo runs from several different
accounts. It mainly matters for local CLI and VS Code resolution rather than for a platform job,
so check the job step above first — but if the index step is already correct and columns are
still missing, fill in `project-id` and `account-host` and try again.

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
