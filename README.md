# Scaling trusted self-service for dbt stakeholders

Hands-on lab · dbt Summit 2026 · 90 minutes · up to 120 participants

Instructors: Kyle Tuft & Matteo Dijoux

---

## What this lab is (and isn't)

This is **not** a modeling lab. The dbt project in this repo already builds and passes. Over the next 90 minutes you'll make it *answer-ready* — so a stakeholder who doesn't write SQL can find a data product, understand it, trust it, know who stands behind it, and get a governed answer without pinging your team.

Everything you do happens in YAML, Markdown, and the dbt platform UI. If you're editing a `.sql` file, you've gone off-script.

## The five components of trusted self-service

The first three make a data product *trustworthy* — and the first of them, people, is what makes someone *accountable* for it. The fourth makes it safely consumable. The fifth turns trusted products into trusted **answers**.

1. **People** — clear ownership; someone stands behind the data
2. **Process** — workflows for questions, requests, and change management
3. **Platform signals** — docs, tests, freshness, lineage, certification
4. **Governed access** — the right people consume the right things, safely
5. **Governed answer surface** — discovery + Semantic Layer + AI that take a stakeholder from question to trusted answer

## The business

Merlin & Co. Apothecaries is a 15-shop potion retail chain across five regions. Wizards buy potions in store, by courier owl, or through a marketplace. Shops brew their own stock from ingredients sourced from regional suppliers, and many customers belong to arcane guilds with tiered memberships.

| Source system | Tables |
|---|---|
| Abracadabra POS | orders, order items, payments, potions |
| Grimoire CRM | customers, guild memberships |
| Alembic Ops | shops, ingredients, brew events, suppliers |

Layers: `models/staging/` (views) → `models/intermediate/` (views) → `models/marts/` (tables).

## Setup (target: under 10 minutes)

1. Incognito window → **workshops.us1.dbt.com/workshop**
2. Select **Scaling trusted self-service for dbt stakeholders**
3. Enter the passcode your instructor gives you at the start of the session
4. Your account initializes from this repo — a personal target schema in `ANALYTICS_WIZARD`, read access to the `RAW_WIZARD.MERLINCO_APOTHECARIES` source
5. Run `dbt build` once. **Do this before Lab 1.** Some tests fail on this dataset by design — your instructor will say which — so flag a TA if you see anything beyond those, or if the build doesn't complete.

Prefer local? Copy `profiles.yml.example` to `~/.dbt/profiles.yml` and fill in every `{placeholder}` — your own Snowflake account, credentials, database, warehouse and role. Watch the last one: `schema: dbt_{flastname}` left as-is won't error, it will silently build every model into a schema literally named `dbt_{flastname}`. You'll also need your own copy of the source tables, since the workshop warehouse is only reachable during the session. The platform IDE is the supported path today.

## The 90 minutes

| Lesson | Time | Format |
|---|---|---|
| **L1** — The pain, and the spark | 12 min | Concept + instructor demo |
| **L2** — Documentation: how the model explains itself | 18 min | 3 concept / **15 lab** → [`labs/01`](labs/01-document-for-humans-and-ai/) |
| **L3** — Trust signals: why the answer is believable | 18 min | 3 concept / **15 lab** → [`labs/02`](labs/02-trust-signals/) |
| **L4** — Ownership & support: who stands behind it | 14 min | 7 concept / **7 lab** → [`labs/03`](labs/03-ownership-and-exposures/) |
| **L5** — Governed access & the answer surface | 22 min | 10 concept / **12 lab** → [`labs/04`](labs/04-governed-access/) |
| **L6** — Recreate the moment + next steps | 6 min | Concept → [`docs/TAKEAWAY_CHECKLIST.md`](docs/TAKEAWAY_CHECKLIST.md) |

Hands-on: 49 of 90 minutes. Each lab folder has a `prompt_*.md` with the task and a "done when" bar. Solutions live on the `solutions` branch — don't peek until your table has had a real go.

## Reference material

- [`docs/STAKEHOLDER_DOC_PATTERNS.md`](docs/STAKEHOLDER_DOC_PATTERNS.md) — the four questions every stakeholder and every AI assistant asks (L2)
- [`docs/QUESTION_BANK.md`](docs/QUESTION_BANK.md) — the stakeholder questions your docs have to survive (L2, L3)
- [`docs/OWNERSHIP_AND_SUPPORT.md`](docs/OWNERSHIP_AND_SUPPORT.md) — ownership register and request routing (L4)
- [`docs/TAKEAWAY_CHECKLIST.md`](docs/TAKEAWAY_CHECKLIST.md) — what to run on your own project Monday (L6)

## Support and maintenance

This repo is the companion project for a 90-minute hands-on lab at dbt Summit 2026. It stays public
after the event so you can revisit the exercises or lift the patterns into your own project.

- **Provided as-is, without SLAs.** Maintained on a best-effort basis by the owning team.
- **Not a supported dbt Labs product.** Nothing here is covered by a dbt Labs support agreement, and
  the code is illustrative rather than production-hardened.
- **Requests and problems:** open a GitHub issue. Pull requests are not accepted on this repo — it
  tracks a specific taught session, so it needs to stay in sync with the lab. Issues are read, but no
  response time is promised.
- **The data is fictional.** Merlin & Co. Apothecaries is generated training data. No real customer,
  company, or production data appears anywhere in this project.
- **You bring your own warehouse.** The workshop environment is only available to attendees during
  the session. To run this afterwards, point `profiles.yml` at your own Snowflake account and load
  your own copy of the source tables — see `models/staging/_merlinco_sources.yml` for the shape.

Licensed under the Apache License 2.0. See [`LICENSE`](LICENSE).
