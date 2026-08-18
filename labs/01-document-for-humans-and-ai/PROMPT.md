# Lab 1 — Document for humans and AI

**Lesson 2 · 15 minutes · individually, compare in pairs**

## The situation

The Merlinco analytics engineering team built a solid project. Models are tested, the DAG is clean, `dbt build` is green. And yet the team fields the same questions every week, and two dashboards report different revenue for the same region.

Nothing is broken. The project simply isn't consumable by anyone who didn't build it — and, as you saw in the opening demo, an AI assistant pointed at it is only as good as what's written down.

## Your task

Take **one** mart model — `fct_order_items` is the richest, `dim_potions` the fastest — and make it explain itself.

1. Open [`docs/QUESTION_BANK.md`](../../docs/QUESTION_BANK.md). Try to answer one question using only what's documented today. Write down every point where you had to guess.
2. Rewrite the model's doc block in `models/marts/_marts__docs.md` — the prose inside the block only; anything you put there ships to the catalog and to Copilot to answer the four questions from [`docs/STAKEHOLDER_DOC_PATTERNS.md`](../../docs/STAKEHOLDER_DOC_PATTERNS.md): what is this, when should I use it, what's the grain, what should I watch out for.
3. Document the columns a stakeholder will actually touch — the ones that appear in a filter or a sum. Say what they *mean*, not what type they are. You do not need to document all of them.
4. Run `dbt parse` to confirm the YAML is valid. Then read your own work back the way a stakeholder would — your instructor will say whether that's **dbt Catalog** in the platform, which refreshes on a job run rather than on your local edits, or the local docs site (`dbt compile --write-index`, then `dbt docs serve` — the server reads the parquet index, not `catalog.json`, and `dbt docs generate` is deprecated in Fusion).

## Constraints

- No SQL. If you're editing a `.sql` file, stop.
- No dbt vocabulary in the "what is this" line — no "fact", "joined", "upstream".
- The watch-out-for section must name at least one thing that would produce a **wrong but believable** number.
- Don't add ownership metadata — `config.meta` owner, groups, exposures — yet. That's Lab 3.

## Done when

Someone who hasn't read your model can answer a question-bank question from your docs alone — including spotting the trap — without asking you anything.

That's the bar. Not "the fields are filled in." Someone else got the right answer unaided.

## If you finish early

Ask **dbt Copilot** to summarize your model, then ask it one of the question-bank questions. Compare its answer before and after your edits. The delta is the entire argument for this lab — screenshot it for your team.
