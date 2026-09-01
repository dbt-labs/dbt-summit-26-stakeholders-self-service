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

Kept out of `models/marts/_marts__docs.md`, because that is the file attendees edit in Lab 1 — put
the answer key in there and you have handed out the answer before the exercise. This is a partial
control, not a real one: `docs/` is a directory attendees clone and Lab 1 links them into it twice.
The actual fix is moving this file and `COURSE_OUTLINE.md` out of the repo, which is on the open
items below.

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
| 1 Document | L2 | 15 | Perfectionism on column docs. Push them to 4–5 columns, and to `grain`/`intended_use`/`caveats` on only two or three of those. Column `meta:` at the top level instead of under `config:` is `dbt1060` — a warning-shaped error that drops the keys, so it's worth calling out before they start rather than after. Watch for anyone writing lab notes *inside* a docs block — it all ships to the catalog. |
| 2 Trust signals | L3 | 15 | `freshness` / `loaded_at_field` at the top level instead of under `config:` (`dbt1060`) — this is the first YAML edit of the day, so it lands hard. Then `dbt source freshness` erroring on static data reading as their mistake. The business-assumption test is `accepted_values` on `order_status` — and it needs the `arguments:` wrapper this project uses, not the shape in the dbt docs, which errors with `dbt1159`. |
| 3 Ownership | L4 | 7 | Exposure YAML shape. Have the snippet ready to paste — this is guided, not discovery. |
| 4 Access | L5 | 12 | Contracts require `data_type` on every column — and `fct_order_items` has 7 columns not yet in the YAML at all, so it's 16 entries to author, not 9. Point anyone short on time at `dim_shops` (5 columns). Step 1 is now `public` plus dbt's default `protected`; nobody should be setting `private`. If someone does and there's no group, it parses clean and enforces nothing — the trap is silence, not an error. |

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
full semantic layer (entities, dimensions, 16 metrics).

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

`access`, `group`, `meta`, `tags`, `contract`, `freshness` and `loaded_at_field` are all **rejected
at the top level** by the engine in this project (dbt-fusion): `[error] [UnusedConfigKey (dbt1060)]: Ignored
unexpected key "access"`. Every one of them must be nested under `config:`. Every dbt doc and blog
post shows the top-level form, so expect this in **every lab from 2 onward** — Lab 2 step 1 is the
first YAML edit of the day and it hits this immediately. Likely the single biggest source of raised
hands all session. The prompts now say so inline, but attendees pattern-match to docs they know.

Two more engine behaviours worth having in your pocket:

- A second `meta:` key under one `config:` block is a hard error, not a silent overwrite:
  `[error] [DuplicateConfigKey (dbt1059)]`. Labs 2 and 3 both write into `meta`, so this will come up.
- Test parameters need the `arguments:` wrapper. The stock docs form (`values:` directly under
  `accepted_values:`) is rejected with `[error] [DbtYamlValidationError (dbt1159)]`. Every existing
  test in the project already uses the wrapper, so "copy the shape next to you" is good advice.
- `groups` require `owner`, and `exposures` require `type` — both surface as
  `[error] [SerializationError (dbt1013)]: YAML error: missing field ...`, which reads like a parser
  problem rather than a missing field. Paste-ready snippets for both are in the Lab 3 prompt.

```yaml
  - name: dim_potions
    config:
      access: public
      group: commerce_analytics
      meta:
        owner: commerce-analytics
```

**`access: private` semantics, tested on 2026-08-14 and worth not re-litigating:**

| Setup | Result on dbt-fusion 2.0.0-preview.205 |
|---|---|
| `access: private`, no group | Parses clean. Manifest shows `access = private, group = None`. Enforces nothing — anything can still `ref` it. |
| `access: private` + a group | `[error] [AccessDenied (dbt1066)]` for every **model** outside that group that `ref`s it. Parse fails. |
| `access: private` + a group, on a **mart** | Parses clean. Tests are exempt from access enforcement, and no mart in this project is `ref`d by another model — so on the models attendees actually touch, this is silent too. |

Both were reproduced directly. The failure mode with no group is silence, not an error, which is
why Lab 4 steers attendees to `public` plus the default and treats `private` as discussion only.
Note the no-group case *is* an error on dbt Core, so if the workshop accounts turn out to run Core
rather than Fusion, re-check this before the day.

## Verified end to end

On 2026-08-14 every lab's YAML step was performed against this project on dbt-fusion
2.0.0-preview.205 and `dbt parse` came back clean: config-nested source freshness with the
`try_to_timestamp_ntz` cast, `not_null` on `potion_sku`, `config.tags` + `config.meta`, a `groups:`
block with an owner, `config.group`, an exposure with `type`, `config.access: public` on the marts,
and an enforced contract on `dim_shops` with `data_type` on all five columns.

Every fenced snippet in `labs/` has also been extracted with its fence indentation stripped and
pasted verbatim into the files the prompts name — all five parse clean. Worth re-running that check
after any edit to a snippet, since an indentation slip in a paste-ready block is invisible on
GitHub and fatal in the room.

Read that as "the YAML is well-formed and the graph resolves", not as full coverage. Five things it
does **not** cover, all of which need checking on the sandbox before the day:

- **Semantic manifest validation is skipped in this project** — every parse emits
  `[warning] [InvalidConfig (dbt1005)]: Skipping semantic manifest validation due to: No
  dbt_cloud.yml config`, because the `dbt-cloud:` block in `dbt_project.yml` is commented out. So
  the interaction between Lab 4's access changes and the semantic models and metrics — the exact
  surface an L1/L5 spark demo queries — has not been observed at all.
- **Nobody has run `dbt build` against the workshop data.** The project ships five singular tests
  plus the `accepted_values` tests, and Lab 2 tells attendees the data "carries deliberate
  messiness". README setup step 5 now says some tests fail by design and that *you* will name which
  — so you have to actually name them. Run a full build on the sandbox, write down the expected
  failures, and brief the TAs, or the disclaimer just moves the confusion rather than removing it.
- **No test packages are installed** (no `packages.yml`), so the only generic tests available are
  `unique`, `not_null`, `accepted_values` and `relationships`. Anything numeric — "price above
  zero", "quantity non-zero" — needs a singular test in a `.sql` file, which the labs forbid. Lab 2
  step 2 was rewritten around `accepted_values` on `order_status` for this reason; if someone asks
  for a numeric assertion, the honest answer is that it needs either a package or a singular test.

- **`dbt source freshness` will error**, not warn, on a static workshop dataset — the Lab 2 prompt
  now tells attendees to expect that and why. Confirm it's an error and not a hard build failure
  that blocks Labs 3 and 4, since `source` is a selectable resource type for `dbt build`.
- **Lab 4 step 3's contract break** is a `data_type` mismatch, which surfaces at build rather than
  parse. Confirm the error message is legible to an attendee.

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
      If a job run is needed, someone has to trigger it at each debrief. The local fallback in Lab 1
      doesn't help most of the room either: `dbt docs serve` binds a local port that attendees on
      the platform IDE can't reach. This is the last unresolved dependency shared by all four labs.
- [ ] **Decide the repo's visibility before the session.** `TAKEAWAY_CHECKLIST.md` tells attendees
      "This repo stays public after the event" and it's the page Lesson 6 says to screenshot; the
      repo is private today. Either flip it or change the line — but flipping it publishes the
      passcode and both planning docs, so these three decisions are one decision.
- [ ] Decide whether the passcode stays in the README, and move **both** `INSTRUCTOR_NOTES.md` and
      `COURSE_OUTLINE.md` out of the attendee repo before it goes public. The outline carries
      milestone dates, the instructor split, PMM flags, and a footer naming a dropped presenter.
      Neither is linked from the README any more, but both sit in a repo attendees clone.
- [ ] **`.mcp.json` was removed** — it pointed at a personal account host (`tk626.us1.dbt.com`)
      inherited from the seed project, while attendees are sent to `workshops.us1.dbt.com`. Editors
      auto-discover that file on repo open, so 120 people would have had a server aimed at the wrong
      account. Re-add it with the real workshop MCP endpoint if the labs need it. The original is at
      `git show 59b8c84:.mcp.json` — pin the SHA, since both `HEAD~1` and `main` stop resolving once
      this branch merges. Four documents still reference the MCP server for the L5 demo, so this
      needs an owner rather than just a checkbox.
- [ ] Fix the region literal if any control answers are written against it — the data says
      `Northern Reaches`, and the docs said `Northern Reach` until 2026-08-14
- [ ] **Verify the guild name literal in Q2.** Regions are pinned by `accepted_values`;
      `guild_name` is not tested anywhere, so "Alchemists' Guild" is unverified. If the seeded value
      differs, one of only three question-bank exercises returns nothing — the same failure the
      region literal had.
- [ ] Build the `solutions` branch with worked answers and control values for the question bank
- [ ] Coordinate with the Semantic Layer and MCP lab teams so the spark demo complements rather than duplicates their sessions
