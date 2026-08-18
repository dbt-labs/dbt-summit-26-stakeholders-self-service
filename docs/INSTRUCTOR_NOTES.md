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

## Lesson 2 debrief — the worked example

Kept here rather than in `models/marts/_marts__docs.md`, because that is the file attendees edit in
Lab 1. Put the answer key in there and you have handed out the answer before the exercise.

Two of the three caveats below are verifiable in the models — check them yourself before teaching
them. The marketplace one is part of the business scenario, not something the models encode; say so
if a sharp attendee asks, because the whole point of the lesson is not publishing caveats you
haven't checked.

> Every potion sold, one row per line on a customer's order.
>
> **Use this for** revenue and unit-volume reporting by shop, region, potion, and channel.
> **Do not use this for** inventory on hand — brewing is not netted against sales here; use
> `fct_brew_events`.
>
> **Grain:** one row per order line. An order containing three different potions appears as three
> rows. Summing revenue across orders is safe; summing it after joining to guild memberships is
> not, because a customer can hold more than one membership at a time.
>
> **Watch out for:**
>
> - Returned and cancelled orders are included at full line value. Discounts *are* netted
>   (`line_net_gold = line_gross_gold - allocated_discount_gold`), but order status is not — filter
>   on `order_status` or you will overstate revenue. *(Verifiable: `fct_order_items.sql` applies no
>   status filter; accepted values are in `_merlinco_staging.yml`.)*
> - Marketplace orders arrive up to 48 hours late, so the current day is always incomplete.
>   *(Scenario, not encoded in the models.)*
> - Prices are carried in both copper and gold. Gold is the reporting standard; copper is retained
>   for reconciliation against the POS system. *(Verifiable: both columns exist on the mart.)*

## Lab timing and failure modes

| Lab | Lesson | Time | Most likely stall |
|---|---|---|---|
| 1 Document | L2 | 15 | Perfectionism on column docs. Push them to 4–5 columns and move on. Watch for anyone writing lab notes *inside* a docs block — it all ships to the catalog. |
| 2 Trust signals | L3 | 15 | YAML indentation on `freshness`; the intentional test failure reading as their mistake. |
| 3 Ownership | L4 | 7 | Exposure YAML shape. Have the snippet ready to paste — this is guided, not discovery. |
| 4 Access | L5 | 12 | Contracts require `data_type` on every column — and `fct_order_items` has 7 columns not yet in the YAML at all, so it's 16 entries to author, not 9. Point anyone short on time at `dim_shops`. |

At 120 people, assume the slowest table is 6–8 minutes behind. Each lab is written so partial completion still lands the point.

## Lesson 4 discussion — the four Monday messages

Walk through the four inbound messages in `OWNERSHIP_AND_SUPPORT.md`, classifying each. The payoff: three of four are symptoms of a missing artifact (docs, an access model, an exposure) rather than a missing answer — which is why hiring another analyst never fixes it.

The access request is the richest one. It asks for more than the person needs. Yes is fast and creates a governance problem you inherit in six months; no without an alternative is why stakeholders build shadow pipelines in spreadsheets. Land the third path.

## Instructor split

Suggested: **L1–L3 / L4–L6**, which puts pain-and-spark with one instructor and the governance build-out with the other. Whoever runs L1 should also run L5's closing demo so the bookend lands in the same voice — worth deciding before the agenda milestone.

While one instructor teaches, the other should be floating. At this room size the non-teaching instructor is the most valuable TA present.

## Naming

**dbt platform** (not "dbt Cloud"), **dbt Catalog**, **dbt Copilot**, **Semantic Layer**, **dbt MCP server**. Naming is mid-transition — confirm with PMM before the deck locks, and check whether "certification" is the current label for maturity markers in Catalog.

## Marts starting state

The labs were drafted as if the marts were thin — undocumented, untested, unowned. They aren't.
`models/marts/_merlinco_marts.yml` carries developer-grade descriptions, grain-key tests, and a
full semantic layer (entities, dimensions, ~20 metrics).

Resolved for now by wiring only the four lab models' descriptions to doc blocks in
`_marts__docs.md`, leaving everything else in place. The doc blocks hold the developer-grade text,
so Lab 1 still has a real "before" to rewrite, and the semantic models and metrics — what any
Semantic Layer demo runs on — are untouched.

What that leaves per lab:

| Lab | Work genuinely missing |
|---|---|
| 1 Document | Yes. Doc blocks are developer-grade prose; column descriptions are terse one-liners. Real work, though less of a blank page than the scaffold assumed. |
| 2 Trust signals | Partly. Freshness is absent, and `not_null` on `potion_sku` is absent. But `unique` + `not_null` on the grain key and the `relationships` test on `potion_sku` **already exist** — the prompt now tells attendees to read those first rather than re-add them. |
| 3 Ownership | Yes. No `meta` owner, no groups, no exposures anywhere. |
| 4 Access | Yes. No `access`, no contracts anywhere. |

**Still open:** whether to strip further for a cleaner blank-page moment in Lab 1. Doing so means
deciding what happens to the grain-key tests and the semantic layer.

## Fusion config nesting — brief the TAs on this

`access`, `group` and `meta` are **rejected at the top level of a model** by the engine in this
project (dbt-fusion): `[error] [UnusedConfigKey (dbt1060)]: Ignored unexpected key "access"`. They
must be nested under `config:`. Every dbt doc and blog post shows the top-level form, so expect
this in Lab 3 step 1, Lab 3 step 2, and Lab 4 step 1 — likely the single biggest source of raised
hands in the back half. The prompts now say so, but attendees pattern-match to docs they already
know.

```yaml
  - name: dim_potions
    config:
      access: public
      group: commerce_analytics
      meta:
        owner: commerce-analytics
```

Note also that `access: private` without a group is a parse-time error in dbt Core but is **not**
enforced by Fusion preview — so Lab 4 step 1's failure mode depends on which engine the workshop
accounts run. Worth pinning down.

## Open items

- [ ] Confirm Semantic Layer + Copilot availability in workshop accounts (blocks L1 and L5)
- [ ] Record the fallback demo video
- [x] Verify mart names in this repo match the YAML scaffold — confirmed 2026-08-14. All four lab
      models exist (`fct_order_items`, `dim_potions`, `dim_shops`, `dim_customers`), as do the
      referenced columns (`unit_price_gold`, `recipe_unit_cost_gold`, `home_region`, `region`).
- [x] Marts starting state — resolved 2026-08-14 by wiring the four lab models to doc blocks
      rather than adding the scaffold's colliding `_marts__models.yml`. See "Marts starting state".
- [ ] Confirm how attendee edits reach **dbt Catalog** — every lab ends with "see it in Catalog",
      but Catalog is built from job-run artifacts and setup only has attendees run `dbt build` once.
      If a job run is needed, someone has to trigger it at each debrief.
- [ ] Decide whether the passcode stays in the README, and move `INSTRUCTOR_NOTES.md` out of the
      attendee repo, before it goes public
- [ ] Build the `solutions` branch with worked answers and control values for the question bank
- [ ] Coordinate with the Semantic Layer and MCP lab teams so the spark demo complements rather than duplicates their sessions
