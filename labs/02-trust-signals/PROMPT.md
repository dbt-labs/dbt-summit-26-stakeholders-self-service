# Lab 2 — Trust signals

**Lesson 3 · 15 minutes · individually or in pairs**

## The situation

A stakeholder opens a data product and decides in about four seconds whether to trust it. They will not read your DAG. They will not check when it last ran unless you show them. Absent a signal they ask a human — or worse, they trust it when they shouldn't.

Trust is a product feature, and it has to be visible at the point of consumption.

## Your task

Make the model you documented in Lab 1 legible to a skeptical stakeholder.

The steps below are written for `fct_order_items`. Whichever model you documented in Lab 1, use its row here — the freshness block belongs on a source actually upstream of your model, and every raw timestamp in this project is stored as text, so each needs a cast.

| Your Lab 1 model | Freshness source | Timestamp to cast | Business-assumption test |
|---|---|---|---|
| `fct_order_items` | `RAW_ORDERS` | `ORDERED_AT` | `accepted_values` on `order_status` |
| `dim_potions` | `RAW_POTIONS` | `INTRODUCED_AT` | `accepted_values` on `category` |
| `dim_shops` | `RAW_SHOPS` | `OPENED_AT` | `accepted_values` on `region` |
| `dim_customers` | `RAW_CUSTOMERS` | `SIGNED_UP_AT` | `accepted_values` on `home_region` |

`dim_potions`, `dim_shops` and `dim_customers` already have `unique` and `not_null` on their grain key, so on those paths go straight to the business-assumption test.

1. **Freshness.** Add freshness to the `RAW_ORDERS` table on the `merlinco_apothecaries` source. Two things to know before you start: both keys go under `config:` (top level fails with `dbt1060`), and `ORDERED_AT` is stored as text, so `loaded_at_field` needs a cast.

   Add these two keys to the **existing** `RAW_ORDERS` entry — don't paste a second `- name: RAW_ORDERS` list item, which dbt resolves by keeping the first definition and quietly discarding yours.

   ```yaml
           config:
             loaded_at_field: try_to_timestamp_ntz(ORDERED_AT)
             freshness:
               warn_after: {count: 24, period: hour}
               error_after: {count: 48, period: hour}
   ```

   Run `dbt source freshness`. **Expect it to fail.** The workshop dataset is static, so anything older than your `error_after` trips immediately — which is itself worth sitting with: a threshold that reflects the business reality of a 48-hour delay is *correct* and still red on this data. Thresholds describe the pipeline you want, not the one you have.

   Then think about what this check could tell you on a *live* pipeline, and what it couldn't. It reads `max(ORDERED_AT)` across the whole table, so in-store and courier-owl orders — which land immediately — would keep it green even while marketplace data sat two days behind. Freshness proves the table is loading. It does not prove the day is complete. That gap is exactly why Q3 in the question bank is a documentation problem and not a monitoring one.
2. **Tests a stakeholder would care about.** Read what `fct_order_items` already has first — `unique` and `not_null` on the grain key, and a `relationships` test on `potion_sku`. Then add what's genuinely missing: `not_null` on `potion_sku`, and one test encoding a *business* assumption: `accepted_values` on `order_status`. The staging model asserts the four valid statuses; the mart a stakeholder actually reads asserts nothing, so a fifth status could appear tomorrow and every revenue filter written against these four would silently start dropping rows.

   This project uses the `arguments:` form for test parameters. The shape you'll find in most dbt docs — `values:` directly under the test — is rejected here with `dbt1159`:

   ```yaml
         data_tests:
           - accepted_values:
               arguments:
                 values: ['completed', 'returned', 'cancelled', 'placed']
   ```

   Note what you *can't* express here. This project has no test packages installed, so the only generic tests available are `unique`, `not_null`, `accepted_values` and `relationships`. "Price is above zero" needs a singular test in a `.sql` file, which is off-limits today — worth knowing, because "we couldn't test the assumption" is itself something the docs then have to carry.
3. **Mark it blessed.** Use `config.meta` and `config.tags` to mark maturity/certification, and set one other mart to `deprecated` with a description line naming what to use instead. Both `meta` and `tags` must sit under `config:` — at the top level of a model they're rejected as unexpected keys (`dbt1060`). You'll add more keys to this same `meta` block in Lab 3; extend it there rather than starting a second one, which errors with `DuplicateConfigKey (dbt1059)`.
4. Explore **lineage and model health in dbt Catalog** from the consumer's point of view. Not the developer's.

For each signal, be ready to say in one sentence what it tells a non-technical consumer to *do differently*. A signal nobody can act on is decoration.

## The trap

One of your tests will probably fail — the seeded data carries deliberate messiness. Before you fix it, answer this: **what should a stakeholder see while a test on a certified mart is failing?**

If your answer is "nothing, they'd hear from us," you've just described the trust incident in Lesson 4.

## Done when

You can name the signals a consumer of this mart can now see without asking anyone, and what each one tells them to do differently.

## Note

Contracts and model access are trust signals too, but they're really *access* guardrails — they come in Lab 4.
