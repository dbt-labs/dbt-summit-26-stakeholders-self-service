# Lab 3 — Ownership and exposures

**Lesson 4 · 7 minutes · guided — follow along with the instructor**

Short and tightly scoped. The concept discussion carries this lesson; the build just makes ownership real in the project.

## Your task

1. **Add an owner.** Put `meta` on your mart: `owner`, `support_channel`, `response_sla`, `maturity`. Use a *team* name, never an individual — people change jobs, and an owner with no stated response expectation isn't an owner.
2. **Define a group.** Create a group in `models/marts/_marts__models.yml` and assign your marts to it, so ownership is structural rather than a comment.
3. **Add an exposure.** Define an `exposure` for the Regional Director's revenue dashboard, depending on your mart plus `dim_shops`. Include an owner name and email.
4. Look at the exposure in **dbt Catalog**. That's the answer to "who breaks if I change this?" — available to you for the first time.

## Why the exposure matters more than it looks

Before an exposure exists, every change is a guess about impact, and you'll guess wrong. After it exists, impact analysis is a lookup. This is also what lets you say yes to stakeholder requests faster: you can see the blast radius rather than fearing it.

`meta` is queryable, so once owners live there you can audit which marts lack one instead of hoping. Try it on your own project next week — the answer is usually uncomfortable.

## Done when

Your mart has a team owner with a support channel and response expectation, belongs to a group, and has at least one registered downstream consumer visible in the catalog.

## For the discussion

Your instructor will walk through four real Monday-morning messages in [`docs/OWNERSHIP_AND_SUPPORT.md`](../../docs/OWNERSHIP_AND_SUPPORT.md). Three of the four are symptoms of a missing artifact, not a missing answer. Which artifact — and why does adding people to the data team never fix it?
