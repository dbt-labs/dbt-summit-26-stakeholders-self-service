# Lab 2 — Trust signals

**Lesson 3 · 15 minutes · individually or in pairs**

## The situation

A stakeholder opens a data product and decides in about four seconds whether to trust it. They will not read your DAG. They will not check when it last ran unless you show them. Absent a signal they ask a human — or worse, they trust it when they shouldn't.

Trust is a product feature, and it has to be visible at the point of consumption.

## Your task

Make the model you documented in Lab 1 legible to a skeptical stakeholder.

1. **Freshness.** Add a `freshness` block to the `RAW_ORDERS` table on the `merlinco_apothecaries` source, with `warn_after` and `error_after` reflecting the 48-hour marketplace delay. `ORDERED_AT` is stored as text, so `loaded_at_field` needs a cast — `try_to_timestamp_ntz(ORDERED_AT)`. Run `dbt source freshness`.
2. **Tests a stakeholder would care about.** Read what `fct_order_items` already has first — `unique` and `not_null` on the grain key, and a `relationships` test on `potion_sku`. Then add what's genuinely missing: `not_null` on `potion_sku`, and one test encoding a *business* assumption, such as quantity never being zero. Check `tests/singular/` before writing one; several assumptions are already covered there.
3. **Mark it blessed.** Use `config.meta` and tags to mark maturity/certification, and set one other mart to `deprecated` with a description line naming what to use instead. Mind the nesting: `meta` at the top level of a model is rejected as an unexpected key (`dbt1060`).
4. Explore **lineage and model health in dbt Catalog** from the consumer's point of view. Not the developer's.

For each signal, be ready to say in one sentence what it tells a non-technical consumer to *do differently*. A signal nobody can act on is decoration.

## The trap

One of your tests will probably fail — the seeded data carries deliberate messiness. Before you fix it, answer this: **what should a stakeholder see while a test on a certified mart is failing?**

If your answer is "nothing, they'd hear from us," you've just described the trust incident in Lesson 4.

## Done when

You can name the signals a consumer of this mart can now see without asking anyone, and what each one tells them to do differently.

## Note

Contracts and model access are trust signals too, but they're really *access* guardrails — they come in Lab 4.
