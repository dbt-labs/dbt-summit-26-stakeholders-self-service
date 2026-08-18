# Lab 4 — Governed access: a curated public interface

**Lesson 5 · 12 minutes · individually**

## The situation

This is where the practitioner's real fear lives: *if I open this up, I lose control.* The answer is that the guardrails do the gatekeeping you've been doing by hand — and you're about to build them.

You've made a model understandable (Lab 1), believable (Lab 2), and accountable (Lab 3). Now make it **safely consumable** — and watch it become answerable.

## Your task

1. **Set access.** Mark your documented marts `access: public` under `config:` — this is the curated interface stakeholders may build on. Top-level `access` is not ignored; it fails the parse with `dbt1060`.

   Then look at what you *didn't* mark. Every other model in the project is `protected`, which is dbt's default: referencable inside the project, not offered as a product. You didn't have to demote anything — `public` is the opt-in, and the line between "data product" and "implementation detail" is drawn by what you chose to promote.

   `private` is the third option, and it's stricter than it sounds: it means "only nodes in the same group may `ref` this". Marking an intermediate model private drops the whole project's parse with `AccessDenied (dbt1066)` unless every downstream consumer joins its group — and on dbt Core that includes the tests that reference it. Worth understanding; not worth your 12 minutes. Stick to `public` and the default.
2. **Enforce a contract** on the public mart so the columns stakeholders depend on can't silently change shape. A contract needs *every* column listed with a `data_type` — `fct_order_items` selects 16 and the YAML documents 9, so budget for the 7 you'll have to add. `dim_shops` is the smaller target if you're short on time. Then `dbt build` and watch it be enforced.
3. **Break it on purpose.** Change a declared `data_type` in the contract to something the model doesn't actually produce — `opened_at` as `varchar` on `dim_shops`, or `quantity` as `varchar` on `fct_order_items` — and run again. Read the error as if you were the consumer who'd have been broken silently, then revert. Do this in the YAML, not the `.sql`; the contract is the promise, and breaking the promise is enough to see it enforced.
4. **Close the loop.** Find your model in **dbt Catalog** as a stakeholder would: documented, owned, certified, public, contracted — with tests and a freshness threshold attached, some of them red on this dataset by design. That's not a failed exercise; a consumer who can *see* a stale source and a failing test is better served than one who sees nothing. This is the product behind the answer you saw in the opening demo.

## The distinction worth internalizing

Read access to a data product should not imply write access to the project, and getting it should not require a Git workflow. Grant on **groups**, never individuals — otherwise offboarding is a manual scavenger hunt. Grant on the **marts layer only**; staging and intermediate shouldn't be discoverable as products at all.

Every grant should trace to a role, not a favor.

## Done when

You have a public, contracted, documented, owned mart, you can say what every other model's `protected` default means, and you can explain to a skeptical colleague why this is *more* control than they had before, not less.

## Watching the spark completed

Your instructor will now ask a plain-language business question against the governed surface — Semantic Layer plus Copilot / the dbt MCP server — and get back a trusted answer with lineage and trust signals attached.

The only reason that answer is trustworthy is the four labs you just did. Nothing about the demo is magic; it's just your metadata, finally legible.
