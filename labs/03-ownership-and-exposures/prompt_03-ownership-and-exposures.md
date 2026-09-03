# Lab 3 — Ownership and exposures

**Lesson 4 · 7 minutes · guided — follow along with the instructor**

Short and tightly scoped. The concept discussion carries this lesson; the build just makes ownership real in the project.

## Your task

1. **Add an owner.** In `models/marts/fct_customer_lifetime_value.yml`, extend the `config.meta` block you started in Lab 2 with `owner`, `support_channel`, and `response_sla` — leave the `maturity` you already set, and add to that block rather than opening a second `meta:` key, which errors with `DuplicateConfigKey (dbt1059)`. Top-level `meta`, `group` and `access` are rejected as unexpected keys (`dbt1060`); they must be nested under `config:`. Use a team name, never an individual — people change jobs, and an owner with no stated response expectation isn't an owner.

```yaml
   config:
     meta:
       maturity: production
       owner:
         name: Commerce Analytics
       support_channel: '#commerce-analytics-support'
       response_sla: '2 business hours for trust incidents'
```

2. **Define a group.** Create a new file, `models/marts/groups.yml`, with a top-level `groups:` block, and assign your mart to it with `config.group` back in `fct_customer_lifetime_value.yml` — so ownership is structural rather than a comment. `owner` is required on a group — omit it and you get `missing field owner` (`dbt1013`). A group isn't owned by one mart, it's shared across every model that joins it — that's why it lives in its own file rather than inside the model.

```yaml
   # models/marts/groups.yml
   groups:
     - name: commerce_analytics
       owner:
         name: Commerce Analytics
         email: commerce-analytics@merlinco.example
```

```yaml
   # models/marts/fct_customer_lifetime_value.yml
   config:
     group: commerce_analytics
```

3. **Add an exposure.** Create a new file, `models/marts/exposures.yml`, defining an `exposure` for the retail ops customer LTV dashboard, depending on your mart. `type` and `owner` are both required — leaving `type` out fails with `missing field type` (`dbt1013`). Same convention as `groups.yml`: an exposure is a claim made *about* the model, from outside it, so it doesn't live inside the model's own file.

```yaml
   # models/marts/exposures.yml
   exposures:
     - name: customer_ltv_dashboard
       type: dashboard
       url: https://bi.merlinco.example/dashboards/customer-ltv
       description: Customer lifetime value, reviewed weekly by retail ops.
       depends_on:
         - ref('fct_customer_lifetime_value')
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