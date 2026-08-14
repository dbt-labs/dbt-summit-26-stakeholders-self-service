# Stakeholder self-service — hands-on lab (dbt Summit 2026)

Companion dbt project for the hands-on lab **"[SESSION TITLE TBD]"** at dbt Summit 2026.

**Session page:** [TBD]

> This project reuses the Merlinco Apothecaries dataset and models originally built for the
> "Creating context with the dbt MCP server" lab
> ([dbt-labs/dbt-summit-26-mcp-server](https://github.com/dbt-labs/dbt-summit-26-mcp-server)).
> The two labs are separate — this repo is the source of truth for the self-service lab.

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
