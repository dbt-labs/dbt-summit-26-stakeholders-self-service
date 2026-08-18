# The four questions

Used in **Lesson 2**.

Most dbt documentation is written by developers, for developers. It describes *what a column contains*. Stakeholders need something different: whether this data product answers their question, and what will bite them if they use it wrong.

Every stakeholder — and every AI assistant — asks the same four things:

1. **What is this?**
2. **When should I use it?**
3. **What's the grain?**
4. **What should I watch out for?**

Four, not fourteen. Four is what people will actually maintain.

## Why this is now double-duty work

Documentation used to be a courtesy to the next human. It isn't anymore. The catalog, the Semantic Layer, and any AI assistant pointed at your project can only describe what you've written down. Copilot cannot tell a stakeholder that the current day is incomplete if nobody documented that the current day is incomplete — it will confidently hand over a wrong-but-believable number instead.

So the docs you write in Lab 1 are not documentation in the old sense. They're the **substrate the answer surface runs on**. Thin descriptions don't produce a vague assistant; they produce a *confidently wrong* one. That's the strongest argument for this work you will ever make to a skeptical practitioner, and it's worth making it out loud.

---

## 1. What is this?

One sentence, business language, no warehouse vocabulary. If it contains "table", "model", "fact", "joined", or "upstream", rewrite it. That's the list the labs use.

> ❌ "Fact table joining order items to potions and shops."
> ✅ "Every potion sold, one row per line on a customer's order."

## 2. When should I use it?

What it's *for*, and — critically — what it is **not** for. The "not for" line prevents more incidents than any test you'll ever write.

> ✅ "Use for revenue and unit-volume reporting by shop, region, potion, and channel. **Do not** use for inventory on hand — and note there's no data product that answers that today: `fct_brew_events` has units brewed, but nothing nets brewing against sales."

Notice what the second half does. "Do not use this for X" is only half an answer; naming what *would* answer it — or admitting nothing does — is what stops someone building it wrong anyway.

## 3. What's the grain?

What one row means, as a sentence rather than a list of key columns. Highest-value line for anyone building their own pivot, because it tells them when they're about to double-count.

> ✅ "One row per order line. An order with three different potions appears three times. Summing revenue across orders is safe; summing it after joining to guild memberships is not, because a customer can hold several memberships."

## 4. What should I watch out for?

The two or three things a well-meaning person would get wrong. Specific and concrete — vague warnings get ignored.

> ✅ "Returned and cancelled orders are included at full line value — discounts are netted, order status isn't — so filter on `order_status` or you'll overstate revenue. Marketplace orders arrive up to 48 hours late, so the current day is always incomplete. Prices are carried in both copper and gold; gold is the reporting standard."

Check every caveat you write against the models before you publish it. A plausible but false warning is worse than no warning — it's the same wrong-but-believable failure this lesson exists to prevent, just authored by you.

---

## Where it goes in dbt

Put the prose in a doc block in `_<layer>__docs.md` so it lives in Markdown instead of being crammed into YAML strings, then reference it from `description`:

```yaml
models:
  - name: fct_order_items
    description: '{{ doc("fct_order_items") }}'
```

Write it once and every consumption path inherits it — the catalog, the Semantic Layer, and any AI assistant reading the project.

**Ownership metadata (`config.meta` owner, groups, exposures) comes in Lesson 4.** Resist adding it now; the point of Lab 1 is that a data product can be perfectly described and still have nobody accountable for it.

## The test for whether your docs are good

Hand them to someone who has never seen the project and ask them to answer a business question. If they come back with a clarifying question, your docs owed them that answer. That's exactly what Lab 1 does to you.
