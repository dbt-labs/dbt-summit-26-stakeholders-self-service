# Stakeholder self-service — hands-on lab (dbt Summit 2026)

Companion dbt project for the hands-on lab **"[SESSION TITLE TBD]"** at dbt Summit 2026.

**Session page:** [TBD]

---

## Source data

| Source system | Tables |
|---|---|
| Abracadabra POS | orders, order items, payments, potions |
| Grimoire CRM | customers, guild memberships |
| Alembic Ops | shops, ingredients, brew events, suppliers |

## Project structure

```
models/
  staging/        # one model per source table, light cleaning only
  intermediate/
  marts/          # dims + facts, materialized as tables
```

## Getting started

[WIP]
