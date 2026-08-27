# Recreate the moment: the checklist

Used in **Lesson 6**. This is the page to screenshot before you leave.

## The eleven things behind one trusted answer

Pick your most-used mart — the one hundreds of decisions run through — and score it.

**Understandable** (Lesson 2)
- [ ] A one-sentence definition in business language
- [ ] Intended use, including what it is **not** for
- [ ] Grain stated as a sentence
- [ ] Two or three specific caveats that would produce wrong-but-believable numbers

**Believable** (Lesson 3)
- [ ] Source freshness thresholds that reflect reality
- [ ] A test encoding a business assumption, not just a uniqueness check
- [ ] A visible maturity/certification marker

**Accountable** (Lesson 4)
- [ ] A team owner with a support channel and a response expectation
- [ ] At least one registered exposure

**Safely consumable** (Lesson 5)
- [ ] `access: public` on the curated interface, and everything else left at dbt's `protected` default. Reach for `private` only deliberately: it means "only the same group may `ref` it", so without a group it does nothing at all, and with one every downstream consumer has to join that group or the project stops parsing
- [ ] An enforced contract on the columns stakeholders depend on

Most teams score two or three. The gap is almost never capability — it's that nobody owns consumability as a deliverable.

## How to roll this out without a six-month project

**Start with exactly one mart.** The most-asked-about one. Do all eleven boxes on that single model, and let it be the reference implementation everyone points at. Breadth-first documentation programs die; depth-first ones get copied.

**Then:**

1. **Week 1** — One blessed mart, fully done. Announce it in the channel where the questions currently arrive.
2. **Week 2** — Audit ownership across all marts by querying `meta`. Publish the list of unowned products. Don't fix them yet; let the gap be visible.
3. **Week 3** — Register exposures for your top five dashboards. You now have impact analysis.
4. **Week 4** — Route inbound requests through the four types. Measure how many were *answerable* — that number is your documentation debt, quantified.
5. **Ongoing** — New mart doesn't reach `production` maturity until it passes the checklist. Make it a definition of done, not a cleanup project.

## The metric that actually matters

How long does it take a new stakeholder to go from "I have a question" to "I have a trustworthy number, without messaging a human"?

Measure it before you start. Everything above exists to shrink it. And if you can only report one number to your leadership about this work, report that one — not the count of documented models.

## Resources

- Sibling Summit labs worth catching: **Standardizing insights with the dbt Semantic Layer** and **Creating context with the dbt MCP server** — both go deeper on the answer surface you saw here
- This repo stays public after the event; the `solutions` branch has a fully worked reference implementation
- Please fill in the session survey — it decides what gets taught next year
