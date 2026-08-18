# Lab 4 — Governed access: a curated public interface

**Lesson 5 · 12 minutes · individually**

## The situation

This is where the practitioner's real fear lives: *if I open this up, I lose control.* The answer is that the guardrails do the gatekeeping you've been doing by hand — and you're about to build them.

You've made a model understandable (Lab 1), believable (Lab 2), and accountable (Lab 3). Now make it **safely consumable** — and watch it become answerable.

## Your task

1. **Set access.** Mark your documented marts `access: public` under `config:` — this is the curated interface stakeholders may build on. Top-level `access` is not ignored; it fails the parse with `dbt1060`. Then mark one mart that *isn't* part of that interface — `fct_customer_guild_memberships` is a good pick — `access: private`, in the same group. You've just drawn the line between "data product" and "implementation detail".

   Resist doing this to an *intermediate* model, tempting as it is. `private` means "only nodes in the same group may `ref` it", so every mart downstream would have to join that group or the whole project stops parsing with `AccessDenied (dbt1066)`. Worth understanding; not worth your 12 minutes.
2. **Enforce a contract** on the public mart so the columns stakeholders depend on can't silently change shape. A contract needs *every* column listed with a `data_type` — `fct_order_items` selects 16 and the YAML documents 9, so budget for the 7 you'll have to add. `dim_shops` is the smaller target if you're short on time. Then `dbt build` and watch it be enforced.
3. **Break it on purpose.** Rename or retype a contracted column and run again. Read the error as if you were the consumer who'd have been broken silently. Then revert.
4. **Close the loop.** Find your model in **dbt Catalog** as a stakeholder would: documented, tested, fresh, owned, certified, public, contracted. This is the product behind the answer you saw in the opening demo.

## The distinction worth internalizing

Read access to a data product should not imply write access to the project, and getting it should not require a Git workflow. Grant on **groups**, never individuals — otherwise offboarding is a manual scavenger hunt. Grant on the **marts layer only**; staging and intermediate shouldn't be discoverable as products at all.

Every grant should trace to a role, not a favor.

## Done when

You have a public, contracted, documented, owned mart and a private upstream model — and you can explain to a skeptical colleague why this is *more* control than they had before, not less.

## Watching the spark completed

Your instructor will now ask a plain-language business question against the governed surface — Semantic Layer plus Copilot / the dbt MCP server — and get back a trusted answer with lineage and trust signals attached.

The only reason that answer is trustworthy is the four labs you just did. Nothing about the demo is magic; it's just your metadata, finally legible.
