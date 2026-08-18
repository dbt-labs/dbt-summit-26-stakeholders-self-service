# Lab 3 — Ownership and exposures

**Lesson 4 · 7 minutes · guided — follow along with the instructor**

Short and tightly scoped. The concept discussion carries this lesson; the build just makes ownership real in the project.

## Your task

1. **Add an owner.** Extend the `config.meta` block you started in Lab 2 with `owner`, `support_channel`, and `response_sla` — leave the `maturity` you already set, and add to that block rather than opening a second `meta:` key, which errors with `DuplicateConfigKey (dbt1059)`. Top-level `meta`, `group` and `access` are rejected as unexpected keys (`dbt1060`); they must be nested under `config:`. Use a *team* name, never an individual — people change jobs, and an owner with no stated response expectation isn't an owner.
2. **Define a group.** Create a top-level `groups:` block in `models/marts/_merlinco_marts.yml` and assign your marts to it with `config.group`, so ownership is structural rather than a comment. `owner` is required on a group — omit it and you get `missing field owner` (`dbt1013`).

   ```yaml
   groups:
     - name: commerce_analytics
       owner:
         name: Commerce Analytics
         email: commerce-analytics@merlinco.example
   ```
3. **Add an exposure.** Define an `exposure` for the regional director's revenue dashboard, depending on your mart plus `dim_shops`. `type` and `owner` are both required — leaving `type` out fails with `missing field type` (`dbt1013`).

   ```yaml
   exposures:
     - name: regional_revenue_dashboard
       type: dashboard
       url: https://bi.merlinco.example/dashboards/regional-revenue
       description: Revenue by shop region, reviewed weekly by the regional directors.
       depends_on:
         - ref('fct_order_items')
         - ref('dim_shops')
       owner:
         name: Commerce Analytics
         email: commerce-analytics@merlinco.example
   ```
4. Look at the exposure in **dbt Catalog**. That's the answer to "who breaks if I change this?" — available to you for the first time.

## Why the exposure matters more than it looks

Before an exposure exists, every change is a guess about impact, and you'll guess wrong. After it exists, impact analysis is a lookup. This is also what lets you say yes to stakeholder requests faster: you can see the blast radius rather than fearing it.

`meta` is queryable, so once owners live there you can audit which marts lack one instead of hoping. Try it on your own project next week — the answer is usually uncomfortable.

## Done when

Your mart has a team owner with a support channel and response expectation, belongs to a group, and has at least one downstream consumer registered in the project — visible in the catalog once your environment refreshes, which may be after the debrief rather than the moment you save.

## For the discussion

Your instructor will walk through four real Monday-morning messages in [`docs/OWNERSHIP_AND_SUPPORT.md`](../../docs/OWNERSHIP_AND_SUPPORT.md). Three of the four are symptoms of a missing artifact, not a missing answer. Which artifact — and why does adding people to the data team never fix it?
