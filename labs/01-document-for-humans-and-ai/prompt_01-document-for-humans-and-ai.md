# Lab 1 — Document for humans and AI

**Lesson 2 · 15 minutes · individually, compare in pairs**

## The situation

The Merlinco analytics engineering team built a solid project. Models are tested, the DAG is clean, `dbt build` is green. And yet the team fields the same questions every week, and two dashboards report different revenue for the same region.

Nothing is broken. The project simply isn't consumable by anyone who didn't build it — and, as you saw in the opening demo, an AI assistant pointed at it is only as good as what's written down.

## Your task

Make `fct_customer_lifetime_value` explain itself. Everyone works on the same model, so you can compare with your neighbour line by line.

1. Try to answer the question below using only what's documented today. Write down every point where you had to guess.

   > "How many customers do we have in the Alchemists' Guild, and what's their average order value?"



2. Rewrite the fct_customer_lifetime_value doc block in `models/marts/_marts__docs.md` — the prose inside the block only; anything you put there ships to the catalog and to Copilot to answer the four questions from [`docs/STAKEHOLDER_DOC_PATTERNS.md`](../../docs/STAKEHOLDER_DOC_PATTERNS.md): what is this, when should I use it, what's the grain, what should I watch out for.


3. Document the columns a stakeholder will actually touch — the ones that appear in a filter or a sum. Column descriptions live in `models/marts/fct_customer_lifetime_value.yml`, not in the docs file you just edited. Say what they *mean*, not what type they are. You do not need to document all of them; four or five is the target.

   Then pick the **two or three columns most likely to be misread** — the ones where two people would defend two different numbers — and take them further than a description. Give each one `grain`, `intended_use` and `caveats` under `config.meta`, so the same four questions you answered for the model are answered again at the column a stakeholder is about to drag into a chart:

   ```yaml
   - name: shop_count
     description: "How many different shops this customer has ever ordered from."
     config:
       meta:
         grain: "Whole customer history, not per year — a loyal customer who moved shops once still counts 2."
         intended_use: "Spotting customers who spread their buying across shops. Not a measure of shop performance — sum it and you double-count nothing meaningful."
         caveats: "A customer who has never ordered shows 0, not null, so an average over this column is dragged down by people who never bought anything."
   ```

   `meta` must be nested under `config:`. At the top level of the column it parses as `dbt1060` and your keys are silently dropped. Free-text values are fine — these are read by people and by Copilot, not by a validator.




4. Run `dbt parse` to confirm the YAML is valid. Then read your own work back the way a stakeholder would — your instructor will say whether that's **dbt Catalog** in the platform, which refreshes on a job run rather than on your local edits, or the local docs site (`dbt compile --write-index`, then `dbt docs serve` — the server reads the parquet index, not `catalog.json`, and `dbt docs generate` is deprecated in Fusion).

## Constraints

- No SQL. If you're editing a `.sql` file, stop. Reading them is how you check your caveats — that's encouraged.
- No dbt vocabulary in the "what is this" line. The banned list is in [`docs/STAKEHOLDER_DOC_PATTERNS.md`](../../docs/STAKEHOLDER_DOC_PATTERNS.md): table, model, fact, joined, upstream.
- The watch-out-for section must name at least one thing that would produce a **wrong but believable** number.
- Every caveat you write must be checkable against the models, or explicitly flagged as business context you were told rather than something you verified.
- Don't add *ownership* metadata — an owner in `config.meta`, groups, exposures — yet. That's Lab 3. The column-level `grain` / `intended_use` / `caveats` keys in step 3 are description, not ownership, and are in scope today.

## Where this question gets hard

Don't read this until you've attempted step 1. It's the list of guesses you were supposed to make — if you found some of them on your own, your instinct is already right.

The question is two questions, and the model answers neither cleanly.

- **"customers in the Alchemists' Guild"** — there is no guild anywhere in this model. That fact alone is worth a line in "when should I use it", because it tells the next person where to go instead, and what happens when they get there.
- **"how many customers"** — one row per customer, but *which* customers? Count them and see whether the number matches your idea of a customer.
- **"average order value"** — there is a column with that name. There is also something else in the project called that. They are not the same number, and neither is `avg()` over the column.

Three different defensible answers to one question is the whole lesson. Your docs don't have to pick one. They have to make the stakeholder aware there's a choice before they take a number into a meeting.

## Done when

Someone who hasn't read your model can answer this question from your docs alone — including spotting the trap — without asking you anything.

That's the bar. Not "the fields are filled in." Someone else got the right answer unaided.

## If you finish early

Ask **dbt Copilot** to summarize your model, then ask it the question above. Compare its answer before and after your edits. The delta is the entire argument for this lab — screenshot it for your team.

Still time? Take a second question from [`docs/QUESTION_BANK.md`](../../docs/QUESTION_BANK.md) and the model it lands on — Q1 goes to `fct_order_items`, Q3 to `fct_orders`. Their doc blocks are in the same file, in the same developer-grade "before" state.
