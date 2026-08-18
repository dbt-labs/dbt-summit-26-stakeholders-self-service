# Ownership and support workflow

Documentation answers questions that have already been asked well. Ownership handles everything else. Lab 3 makes ownership real in the project; this page is the take-home version — fill the register in for your own marts on Monday. It's the artifact most worth leaving with.

## Ownership register

One row per data product that stakeholders are allowed to consume directly. If a model isn't in this table, it isn't self-service — it's just a table someone found.

| Data product | Owning team | Support channel | Response expectation | Maturity |
|---|---|---|---|---|
| `fct_order_items` | | | | |
| `dim_potions` | | | | |
| `dim_shops` | | | | |
| `dim_customers` | | | | |

**Maturity** is a promise about stability, and it's the cheapest trust signal you can ship:

- `production` — supported, tested, changes are announced in advance
- `beta` — usable, but the shape may change without notice
- `deprecated` — a replacement exists and is named in the description; stop building on it

## Four Monday-morning messages

Read these before the taxonomy below, and classify each one. Three of the four are symptoms of a
missing artifact rather than a missing answer — which is why adding another analyst never fixes it.

> **09:02 — regional director, Northern Reaches**
> "Morning. Do we have potion revenue by region anywhere? I've been pulling it off the shop export,
> but Marcus has a different number for the same quarter and neither of us can work out why."

> **09:14 — guild partnerships analyst**
> "Can I get warehouse access? Ideally whatever the analytics engineers have, so I'm not blocked
> every time I need to check something."

> **09:31 — head of retail ops**
> "Can you add repeat customer rate to the orders mart? Per shop, per month. Board deck is Thursday."

> **09:40 — finance lead**
> "The revenue tile on the exec dashboard is down 30% from Friday. Did something change on your end?"

## The four inbound request types

Nearly every stakeholder request is one of four things. Naming them is what lets you route instead of triage from scratch each time.

| Type | Signal | Route | Target |
|---|---|---|---|
| **Answerable** | The answer is already in the docs or an existing mart | Point to the doc; if they couldn't find it, that's a docs bug — file it | Same day |
| **Access** | They have the right data product but can't reach it | Access workflow, group-based not individual | 1 business day |
| **New definition** | They need a metric or field that doesn't exist yet | Intake queue, prioritized with the requesting team | Triaged in 1 week |
| **Trust incident** | Numbers look wrong, or two reports disagree | Named owner, treated as an incident, root cause shared publicly | Acknowledged in 2 hours |

The failure mode in most organizations is that all four arrive in the same DM to the same person, and get handled at the speed of the slowest one.

## Change management

Stakeholders will only build on your data products if changes don't surprise them. Minimum viable contract:

1. **Announce breaking changes before shipping.** A renamed or dropped column in a `production` mart gets notice in the support channel and a deprecation window.
2. **Model versions for real breaks.** Use dbt model versions rather than renaming in place, so existing consumers keep working while they migrate.
3. **Register consumers as exposures.** If a dashboard depends on a mart, it's an `exposure` in the project. Otherwise you're guessing about impact every time you change something — and you'll guess wrong.
4. **One announcement channel, not five.** People opt out of noise. Keep change announcements separate from questions.

## Access model

The goal is to expand governed consumption without handing out developer workflows.

- Grant on **groups**, never individuals — offboarding is otherwise a manual scavenger hunt
- Grant on the **marts layer only**; staging and intermediate are implementation detail and should not be discoverable as products
- Read access to data products should not imply write access to the project, and shouldn't require a Git workflow to obtain
- Every grant should be traceable to a role, not a favor

## The question worth asking your own team

How long does it take a new stakeholder to go from "I have a question" to "I have a trustworthy number, without messaging a human"? That number is your actual self-service maturity. Everything above exists to shrink it.
