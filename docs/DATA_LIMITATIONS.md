# Known limitations of the Merlinco dataset

This project is the worked reference implementation for the lab. It is scored against
[`TAKEAWAY_CHECKLIST.md`](TAKEAWAY_CHECKLIST.md) and scores all eleven boxes — but it runs on
generated training data, and in a few places the data cannot support the signal the pattern
calls for. Those places are listed here rather than papered over.

Writing this page down *is* the pattern. A caveat you know about and haven't published is
indistinguishable, to a consumer, from one you never noticed.

## There is no load timestamp anywhere in RAW

Every timestamp in the source data is a **business event** time — when an order was placed,
when a payment was attempted, when a batch was brewed — stored as text. None of them record
when the row arrived in the warehouse.

Business time and load time answer different questions:

- *Is the pipeline running?* needs load time.
- *How recent is the newest activity?* needs event time.

`dbt source freshness` is built for the first question. With no load timestamp, this project
answers the second one on the tables that can support it, and falls back to warehouse metadata
elsewhere. [`models/staging/_merlinco_sources.yml`](../models/staging/_merlinco_sources.yml)
labels every table with which tier it uses:

| Tier | Mechanism | Tables | What it actually proves |
|---|---|---|---|
| A | `loaded_at_field` on a cast event timestamp | `RAW_ORDERS`, `RAW_PAYMENTS`, `RAW_BREW_EVENTS`, `RAW_CUSTOMERS` | The newest event is recent. Not that the load finished, and not that the day is complete. |
| B | `loaded_at_query` borrowing a parent table's clock | `RAW_ORDER_ITEMS`, `RAW_POTION_INGREDIENTS` | The parent's newest event is recent. Breaks silently if the child ever loads separately from the parent. |
| C | `freshness` with no `loaded_at_field` (warehouse `last_altered`) | `RAW_SHOPS`, `RAW_SUPPLIERS`, `RAW_POTIONS`, `RAW_INGREDIENTS`, `RAW_GUILDS`, `RAW_GUILD_MEMBERSHIPS` | The table was written recently. Nothing at all about completeness or correctness. |

### Why the Tier A and B checks are red, and why that is correct

The dataset is static and deterministically generated. Its newest order is fixed in time, so
every Tier A and Tier B check trips `error_after` the moment you run it and will never go
green without regenerating the data.

**This is not a misconfiguration.** The thresholds describe the pipeline Merlinco would want —
a 48-hour delay on order data is a real incident — and a threshold that reflects business
reality is *correct* even when the data in front of it is a fixture. Loosening them to
`error_after: 10 years` to get a green run would be the actual mistake: it would produce a
check that can never fire, which is worse than no check because it looks like coverage.

A consumer who can see a stale source is better served than one who sees nothing.

### Two ways to fix this properly

Neither is done, and both are worth doing if this dataset gets another pass:

1. **Have the generator emit a `_LOADED_AT` column per table**, set to generation time. One
   column per table, and every source moves to honest Tier A freshness. It would also let Lab 2
   teach load time versus event time as a *contrast* rather than as a caveat, which is the
   better lesson. Tracked against
   [`dbt-labs/merlinco-apothecaries`](https://github.com/dbt-labs/merlinco-apothecaries).
2. **Add a `RAW_INGESTION_AUDIT` companion table** (`table_name`, `loaded_at`, `row_count`) for
   `loaded_at_query` to point at. Less invasive, and it models what a real ingestion tool
   provides.

## Every raw timestamp is stored as text

`ORDERED_AT`, `PAID_AT`, `BREWED_AT`, `SIGNED_UP_AT` and the rest are `varchar` in `RAW`, so
every one needs a `try_to_timestamp_ntz` or `try_to_date` cast in staging, and
`loaded_at_field` needs the cast inline.

`try_to_*` returns null rather than failing on unparseable input. That is deliberate — it keeps
one bad row from failing the whole build — but it means **a cast failure looks exactly like a
missing value**. Any column described here as "empty where the source recorded something
unreadable" is carrying that ambiguity. On a real pipeline you would test the null rate rather
than trusting it.

## Deliberate messiness in the source data

The generator seeds realistic dirt, which is why some tests are red by design. See
[`EXPECTED_FAILURES.md`](EXPECTED_FAILURES.md) for the list and the reasoning. Known shapes:

- Region codes arrive in mixed forms (`nr`, `Northern Reaches`, `northern reaches`) —
  canonicalized by `merlinco_normalize_region`.
- Booleans arrive as `Y`/`no`/`TRUE`/`FALSE`/`1`/`0` — normalized by
  `merlinco_normalize_boolean`, which returns null for anything it doesn't recognize.
- Some ingredients reference suppliers that are not in `RAW_SUPPLIERS`.
- Some quality checks are blank.

## The 48-hour marketplace delay is scenario, not data

The caveat that marketplace orders arrive up to 48 hours late — carried on `fct_orders` and
`fct_order_items`, and the whole point of question bank Q3 — is **business context we were
told**. It is not verifiable against this dataset, and it is labelled as such everywhere it
appears.

Knowing which of your caveats are checkable and which are received wisdom is the discipline the
lab is teaching. A plausible but false warning is worse than no warning.

## Contract data types are inferred, not measured

The `data_type` values on the contracted data products were derived by reading the casts in
staging and intermediate, not from `information_schema`. The straightforward ones — `varchar`,
`date`, `timestamp_ntz`, `number(18,2)` — are safe. The **aggregate-derived numerics** are the
risk: `count(*)`, `count_if`, `sum()` over an already-typed column, and `datediff` each have a
precision Snowflake picks, and a contract fails the build on a precision mismatch.

The first `dbt build` against a real warehouse will name the actual type in the error if any
declaration is wrong. Columns to check first:

- `fct_customer_lifetime_value.lifetime_order_item_count` — declared `number(38,0)` (a `sum`
  over a `number(18,0)`)
- `fct_customer_lifetime_value.days_to_first_order` / `days_since_last_order` — declared
  `number(9,0)` (`datediff`)
- every `*_count` column declared `number(18,0)`

## Row counts are small

Fifteen shops and a few thousand orders. Enough to demonstrate every pattern here; not enough
for the performance conversation. Nothing in this project is incrementally materialized,
partitioned or clustered, and on this volume it shouldn't be — but do not read the
materialization choices as guidance for a real warehouse.
