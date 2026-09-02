# Stakeholder question bank

These are the questions your documentation has to survive. They're written the way stakeholders actually write them — imprecise, with a hidden trap in each one.

Used in Lab 1 (Lesson 2) and Lab 2 (Lesson 3). TAs: control answers are on the `solutions` branch.

---

### Q1 — from the regional director, Northern Reaches

> "Can you send me potion revenue by region for last quarter? I want to compare against the shop targets."

*Hidden trap:* region exists on both the shop and the customer (`home_region`). Revenue by shop region and revenue by customer region are different numbers, and both are defensible. Good docs make the stakeholder aware there is a choice to make before they build the report and defend it in a meeting.

---

### Q2 — from the guild partnerships manager — **this is the Lab 1 question**

> "How many customers do we have in the Alchemists' Guild, and what's their average order value?"

Lands on `fct_customer_lifetime_value`. Four traps stacked, three of them checkable in the models:

- **No guild in the model at all.** Getting one means joining `fct_customer_guild_memberships`, which is at one row per *membership interval*, effective-dated with `valid_from` / `valid_to`. A customer can hold several. The naive join fans out the rows and inflates both the customer count and the revenue. `int_merlinco_current_guild_memberships` is the current-only view, and `is_current_membership` is the flag on the fact.
- **The grain includes customers who never ordered.** `int_merlinco_customer_lifetime_rollup` left-joins the order rollup onto all customers and coalesces to 0, so `count(*)` is signed-up customers, not buyers. `has_ordered` is the flag, and nothing currently says so.
- **"Average order value" exists twice, with two definitions.** The column `average_order_value_gold` is lifetime net revenue over `billable_order_count` — cancelled orders excluded, **returned orders included at full value** — and it is `NULL` for anyone who never placed a billable order. The `average_order_value` metric on `fct_orders` is a plain average per order, cancelled included. And `avg()` over the column is a third number: an unweighted average of averages. The interesting question isn't whether a definition exists, it's whether the stakeholder knows which one they're getting and where they'd find out.
- **`days_since_last_order` is relative to the run date**, so it moves without the data changing.

Three defensible answers to one question. Good docs don't have to pick one — they have to surface the choice before the number reaches a meeting.

---

### Q3 — from the head of retail ops

> "Yesterday's sales look way down versus the day before. What's going on?"

*Hidden trap:* marketplace orders land up to 48 hours late, so the most recent day is structurally incomplete. This is not a data quality problem — it's a documentation problem, and it will burn hours of investigation every single time until it's written down where consumers look.

---

## How to use these

For each question, at your table:

1. Answer it using **only** the project documentation as it exists right now. Note exactly where you got stuck or had to guess.
2. Every guess you made is a gap in the docs. Fix that gap using the four questions.
3. Hand your updated docs to the table next to you and have them try the same question cold. If they still have to ask you something, you're not done.

That last step is the whole lab in miniature. Documentation you wrote is always clear to you — clarity is only observable from the outside.
