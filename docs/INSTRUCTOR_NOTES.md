# Instructor and TA notes

Not needed by attendees. Feeds the TA Guide milestone (due Aug 21).

## Story arc

Open on the pain → hit the spark early → spend the lab earning the trust behind it → close by handing over the checklist.

The audience is **not** the stakeholder. It's the practitioner who'd have to let go of being the gatekeeper. Their need to believe: *"I can open data up without drowning in cleanup, wrong numbers, or losing control."* Every lab should land as evidence for that, not as a feature tour.

## Lesson 1 — the spark demo (12 min, instructor only)

A non-developer asks a real business question in plain language and gets a trusted, governed answer with lineage and trust signals attached.

**Run this from the instructor account, not the attendee sandbox.** A live natural-language ask can't be run uniformly for 120 people, and it doesn't need to be — it's the promise, not the exercise. Attendees complete the loop in Lab 4 by seeing their own model as a finished product.

**Risk to close out before the deck is final:** confirm the workshop accounts have Semantic Layer and Copilot enabled, or that the demo runs from a separate pre-configured project. Worth confirming with Beth explicitly — the entire arc hangs off this 90 seconds, and a failure in the first 12 minutes costs the room's trust for the remaining 78.

**Delivery options (undecided):**

| Option | Strength | Cost |
|---|---|---|
| Live | Strongest proof; nothing beats a real answer appearing | Highest risk; depends on account entitlements and the network |
| Pre-recorded | Near-live impact, zero risk, repeatable, narratable over the top | Small credibility discount; a skeptic may assume it's staged |
| Annotated screenshots | Bulletproof; works with no environment at all | Weakest — shows the output but not that it happened in seconds |

If it stays undecided, **record the flow anyway**. A recording costs an hour, converts into the fallback, and doubles as an asset for the deck and for post-event follow-up. Screenshots can be pulled from the recording, so recording is the option that keeps every other option open. Note that the L1 and L5 slides differ depending on the choice, so decide before the deck locks.

**Suggested question for the demo:** something with a real trap in it, ideally one from `docs/QUESTION_BANK.md`. An assistant handling the guild fan-out correctly *because the grain was documented* is a far better spark than a clean aggregate any BI tool could produce.

## Lab timing and failure modes

| Lab | Lesson | Time | Most likely stall |
|---|---|---|---|
| 1 Document | L2 | 15 | Perfectionism on column docs. Push them to 4–5 columns and move on. |
| 2 Trust signals | L3 | 15 | YAML indentation on `freshness`; the intentional test failure reading as their mistake. |
| 3 Ownership | L4 | 7 | Exposure YAML shape. Have the snippet ready to paste — this is guided, not discovery. |
| 4 Access | L5 | 12 | Contracts require `data_type` on every column; this trips nearly everyone. |

At 120 people, assume the slowest table is 6–8 minutes behind. Each lab is written so partial completion still lands the point.

## Lesson 4 discussion — the four Monday messages

Walk through the four inbound messages in `OWNERSHIP_AND_SUPPORT.md`, classifying each. The payoff: three of four are symptoms of a missing artifact (docs, an access model, an exposure) rather than a missing answer — which is why hiring another analyst never fixes it.

The access request is the richest one. It asks for more than the person needs. Yes is fast and creates a governance problem you inherit in six months; no without an alternative is why stakeholders build shadow pipelines in spreadsheets. Land the third path.

## Instructor split

Suggested: **L1–L3 / L4–L6**, which puts pain-and-spark with one instructor and the governance build-out with the other. Whoever runs L1 should also run L5's closing demo so the bookend lands in the same voice — worth deciding before the agenda milestone.

While one instructor teaches, the other should be floating. At this room size the non-teaching instructor is the most valuable TA present.

## Naming

**dbt platform** (not "dbt Cloud"), **dbt Catalog**, **dbt Copilot**, **Semantic Layer**, **dbt MCP server**. Naming is mid-transition — confirm with PMM before the deck locks, and check whether "certification" is the current label for maturity markers in Catalog.

## Marts starting state — unresolved

The labs assume the marts are thin: undocumented, untested, unowned. The project as inherited is
not thin. `models/marts/_merlinco_marts.yml` already carries developer-grade descriptions, `unique`
/ `not_null` / `relationships` tests on every grain key, and a full semantic layer — entities,
dimensions, and ~20 metrics.

What that means per lab:

| Lab | Work still genuinely missing? |
|---|---|
| 1 Document | Mostly. Descriptions exist but are developer-grade ("Order item fact at one row per order line") — a fair "before" state, though thinner than the scaffold assumes. Column descriptions are already filled in and would need stripping. |
| 2 Trust signals | Partly. Freshness is genuinely absent. But `unique` on the grain key and `not_null` on the SKU **already exist** — as written, that step is a no-op. |
| 3 Ownership | Yes. No `meta` owner, no groups, no exposures anywhere. |
| 4 Access | Yes. No `access`, no contracts anywhere. |

Whatever we choose, the semantic models and metrics are worth protecting — they're what a Semantic
Layer spark demo would run on.

## Open items

- [ ] Confirm Semantic Layer + Copilot availability in workshop accounts (blocks L1 and L5)
- [ ] Record the fallback demo video
- [x] Verify mart names in this repo match the YAML scaffold — confirmed 2026-08-14. All four lab
      models exist (`fct_order_items`, `dim_potions`, `dim_shops`, `dim_customers`), as do the
      referenced columns (`unit_price_gold`, `recipe_unit_cost_gold`, `home_region`, `region`).
- [ ] **Decide the marts starting state** — the scaffold's `_marts__models.yml` collides with the
      existing `_merlinco_marts.yml` (dbt error `dbt1005`, duplicate resource definitions). See
      "Marts starting state" below. Blocks committing the scaffold YAML.
- [ ] Build the `solutions` branch with worked answers and control values for the question bank
- [ ] Coordinate with the Semantic Layer and MCP lab teams so the spark demo complements rather than duplicates their sessions
