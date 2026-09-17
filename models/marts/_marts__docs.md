<!--
REFERENCE IMPLEMENTATION.

Everything inside a docs block below is compiled into the model's `description` and shipped
to dbt Catalog, the Semantic Layer, and any AI assistant reading this project — HTML
comments included. Keep notes out here, above the blocks, where dbt ignores them. (Don't
write a docs tag inside this comment either; dbt reads the tag, not the comment around it,
and will swallow the block below.)

Every block follows the four questions in docs/STAKEHOLDER_DOC_PATTERNS.md — what is this,
when should I use it, what's the grain, what should I watch out for — and none of them use
the banned vocabulary (table, model, fact, joined, upstream).

Caveats marked "business context" were told to us, not verified against the project. Every
other caveat here is checkable in the SQL. Knowing which is which is the discipline.
-->

{% docs fct_customer_lifetime_value %}

Everything Merlin & Co. knows about one wizard's buying history, summarized into a single
row each.

**When to use it.** Lifetime spend, order counts, first and last purchase dates, and
repeat-buyer questions at the level of an individual customer. Good for cohort work,
loyalty segmentation, and "who are our best customers".

**Not** for guild questions — there is no guild or membership information here at all. For
those, start from `fct_customer_guild_memberships`, and read its caveats first: a wizard
can hold several memberships over time, so counting customers after bringing membership
alongside will inflate the count unless you keep only current memberships.

**Grain.** One row per wizard who has ever signed up — including the ones who have never
bought anything. That is roughly the whole signup list, not the buyer list.

**Watch out for:**

- **Non-buyers are in here, and they are counted.** Counting rows gives you signed-up
  wizards, not customers who bought something. Filter on `has_ordered` first. This single
  thing is the most common wrong-but-believable number this data produces.
- **Absence looks different depending on which column you read.** For a wizard who never
  ordered, the spend columns show `0` but `average_order_value` shows nothing at all
  (empty). So an average over the spend columns is dragged down toward zero by non-buyers,
  while an average over `average_order_value` silently skips them. Same row, two different
  meanings of "nothing".
- **"Average order value" means three different things in this project.** The column here
  is one of them. See the column's own notes before you put it in front of anyone.
- **`days_since_last_order` moves on its own.** It is measured against the day the data
  was last refreshed, so the same wizard's number changes overnight with no new purchase.
  Never screenshot it as a fixed figure.
- **Returned purchases are still counted as spend** in every lifetime column except
  `returned_revenue`, which isolates them. Cancelled purchases are excluded throughout.

{% enddocs %}


{% docs fct_order_items %}

Every potion sold, one row per line on a wizard's order.

**When to use it.** Revenue and unit-volume reporting broken down by shop, region, potion,
potion category, and sales channel. This is the right starting point for "what sold, where,
and for how much".

**Not** for stock on hand. Nothing in Merlin & Co.'s data answers that today:
`fct_brew_events` records how much was brewed, but nothing subtracts what was sold from
what was made. If someone asks for inventory, the honest answer is that it doesn't exist
yet.

**Grain.** One row per line on an order. An order containing three different potions
appears three times. Adding up spend across orders is safe. Adding it up after bringing
guild memberships alongside is not, because a wizard can hold several memberships and each
one duplicates their purchases.

**Watch out for:**

- **Returned and cancelled orders are included at full value.** Discounts are already
  subtracted; order status is not. Filter on `order_status` or you will overstate revenue.
- **The most recent day is always incomplete.** Marketplace orders arrive up to 48 hours
  after the purchase, so yesterday's total will rise for two more days. This is normal and
  is not a data problem. *(Business context — told to us, not verifiable here.)*
- **Money appears in two currencies.** Columns ending `_copper` and `_gold` describe the
  same purchase; 100 copper is 1 gold. Gold is the reporting standard — mixing them
  inflates totals by 100x.
- **The discount on a line is an allocation, not a real discount.** Discounts are struck at
  the order level and spread across lines in proportion to line value, with rounding
  pennies pushed onto the last line. A single line's discount is therefore an estimate; the
  order's total discount is exact.

{% enddocs %}


{% docs dim_potions %}

The catalog of everything Merlin & Co. sells, one row per product, with what it costs to
brew.

**When to use it.** Describing and grouping potions — by category, price, potency, shelf
life, or whether the recipe uses something hazardous. Bring it alongside sales or brewing
data to break those down by product.

**Not** for what sold or what was brewed. This is the catalog only, so counting rows counts
products offered, not products moved.

**Grain.** One row per potion. Products that have been retired are still listed, so this is
everything ever offered rather than everything currently for sale.

**Watch out for:**

- **`recipe_unit_cost_gold` is 0 for potions with no recipe recorded**, not empty. A margin
  calculation against this will show those potions as pure profit. Check
  `recipe_ingredient_count` is above 0 before trusting the cost.
- **Recipe cost is the cost of ingredients for one unit at today's ingredient prices.** It
  is not what the potion actually cost to brew historically, and it excludes labour and
  cauldron time.
- **`is_regulated` can be empty** where the source system recorded something unreadable.
  Empty means "we don't know", not "not regulated" — treating it as false will understate
  the regulated range.
- **Money appears in two currencies.** `_copper` and `_gold` describe the same price; gold
  is the reporting standard.

{% enddocs %}


{% docs dim_shops %}

The fifteen Merlin & Co. shop fronts, one row each, with where they are and when they
opened.

**When to use it.** Grouping or filtering anything by shop, city, or region. This is the
source of truth for which region a *shop* sits in.

**Not** for shop performance — there are no sales or staffing numbers here. Bring it
alongside sales data for that.

**Grain.** One row per shop, including any that have since closed.

**Watch out for:**

- **"Region" means two different things in this project.** The region here is where the
  *shop* is. Wizards also have a home region, which is where the *customer* lives, and a
  wizard in one region regularly buys from a shop in another. Revenue by shop region and
  revenue by customer region are different, equally defensible numbers. Pick deliberately
  and say which one you used.
- **`opened_at` can be empty** where the source recorded an unreadable date. Filtering on
  it silently drops those shops along with their sales.

{% enddocs %}


{% docs dim_customers %}

Every wizard who has ever signed up with Merlin & Co., one row each, with where they live
and how many guilds they currently belong to.

**When to use it.** Describing and grouping wizards — by home region, signup date, favoured
discipline, or current guild count. This is the source of truth for which region a
*customer* lives in.

**Not** for spending or order history; that's `fct_customer_lifetime_value`. And not for
guild detail — `current_guild_count` is a count only, with no indication of which guilds or
at what tier. `fct_customer_guild_memberships` has that.

**Grain.** One row per wizard who has signed up, whether or not they have ever bought
anything.

**Watch out for:**

- **Most of these wizards may never have bought anything.** Counting rows counts signups,
  not customers.
- **"Region" means two different things in this project.** The home region here is where
  the *wizard lives*, which is often not the region of the shop they buy from. See
  `dim_shops`.
- **`current_guild_count` is as of the last refresh and is 0, not empty, for non-members.**
  An average over it is pulled down by every wizard who has never joined a guild.
- **`birth_year` can be empty** where the source recorded something unreadable, so age
  bandings will quietly exclude those wizards.

{% enddocs %}


{% docs dim_guilds %}

The arcane guilds Merlin & Co.'s wizards can belong to, one row each.

**When to use it.** Putting guild names onto membership records, and grouping by guild. This
is where you come to turn a guild code into the name a person would recognize, such as the
Alchemists' Guild.

**Not** for who belongs to what — that's `fct_customer_guild_memberships`. Counting rows
here counts guilds that exist, not guilds with members.

**Grain.** One row per guild.

**Watch out for:**

- **A guild with no members still appears here.** Bringing membership alongside and counting
  will show it with zero, which is correct but easy to misread as missing data.
- **`founded_year` can be empty** where the source recorded something unreadable.

{% enddocs %}


{% docs dim_suppliers %}

The regional houses Merlin & Co. buys brewing ingredients from, one row each.

**When to use it.** Grouping ingredients or brewing costs by supplier or supplier region,
and filtering on how reliable a supplier is.

**Not** for purchasing volume or spend with a supplier — Merlin & Co. records no purchase
orders, so there is no data product that answers "how much do we buy from them".

**Grain.** One row per supplier, including any no longer under contract.

**Watch out for:**

- **`reliability_rating` is a score carried over from the sourcing system** with no
  documented scale or refresh date. Treat it as a rough ranking, not a measurement.
- **Supplier region is a third kind of region**, alongside shop region and customer home
  region. Don't mix them in one breakdown.

{% enddocs %}


{% docs dim_ingredients %}

Everything that goes into a potion, one row per ingredient, with what it costs and who
supplies it.

**When to use it.** Ingredient-level cost and sourcing questions, and flagging recipes that
involve hazardous material.

**Not** for how much of an ingredient is in stock or has been consumed. Merlin & Co. tracks
neither.

**Grain.** One row per ingredient.

**Watch out for:**

- **`supplier_name` can be empty** when an ingredient points at a supplier that isn't on
  record. Those ingredients disappear from any breakdown by supplier, taking their cost
  with them.
- **`unit_cost_gold` is the current price, not the price at the time of purchase.** Any
  historical cost built from it is restated at today's prices.
- **`is_hazardous` can be empty** where the source recorded something unreadable. Empty
  means unknown, not safe.
- **Units are not comparable across ingredients.** A pinch and a bundle both appear; adding
  quantities across different units produces a meaningless number.

{% enddocs %}


{% docs fct_orders %}

Every purchase a wizard has made, one row per order, with what it was worth and whether it
was paid for.

**When to use it.** Order counts, order value, discounting, and payment outcomes at the
level of a whole purchase. This is the right place for "how many orders" and "what's our
average order value" questions.

**Not** for what was in the order — use `fct_order_items` for anything broken down by potion
or category.

**Grain.** One row per order, whatever its status, including cancelled ones.

**Watch out for:**

- **Cancelled and returned orders are included.** Counting rows counts attempts, not sales.
  Filter on `order_status`.
- **The most recent day is always incomplete.** Marketplace orders arrive up to 48 hours
  late. *(Business context — told to us, not verifiable here.)*
- **The payment columns describe attempts, not settlement.** A wizard who retried a failed
  payment shows more than one attempt on a single order, and `successful_payment_gold` can
  differ from order value in both directions — part payments down, retries up. It is not a
  substitute for what was actually collected.
- **An order with no lines recorded still appears**, showing 0 gross and a negative net
  equal to its discount. Rare, and it will quietly drag down any average.
- **"Average order value" means three different things in this project.** The one defined
  here is the plain average across orders, cancellations included.

{% enddocs %}


{% docs fct_payments %}

Every attempt a wizard made to pay for an order, one row per attempt.

**When to use it.** Payment failure and refund analysis, and comparing payment methods.
This is the only place with attempt-by-attempt detail.

**Not** for revenue. An order can be attempted several times and refunded later, so adding
these up does not give you sales. Use `fct_orders` or `fct_order_items` for revenue.

**Grain.** One row per payment attempt. One order can appear many times, or not at all if
nobody ever tried to pay.

**Watch out for:**

- **Adding up every row double-counts.** Successes, failures and refunds are all in here
  together. Always filter on `payment_status` first.
- **Refunds are positive numbers, not negative.** Subtract them deliberately; adding them
  to successes inflates collections.
- **Superseded for order-level questions.** Attempt counts and amounts per order are
  already summarized onto `fct_orders`, which is the supported path. See the deprecation
  note on this data product.

{% enddocs %}


{% docs fct_brew_events %}

Every batch of potion a shop has brewed, one row per batch, with an estimate of what it
cost to make.

**When to use it.** Production volume, brewing quality rates, cauldron time, and estimated
production cost by shop, potion, or brewer.

**Not** for stock on hand. This records what was made and nothing subtracts what was sold,
so a running total here is not inventory. And not for sales — brewing a batch is not
selling it.

**Grain.** One row per brewing batch. A shop brewing the same potion twice in a day appears
twice.

**Watch out for:**

- **`sellable_units_brewed` is 0 for any batch that failed its quality check**, while
  `batch_size` still shows the full amount. Using `batch_size` as production output
  overstates what Merlin & Co. can actually sell.
- **`estimated_batch_cost_gold` is an estimate at today's ingredient prices**, and is 0 for
  any potion with no recipe recorded. Those batches look free.
- **`brewer_name` is free text from the shop system**, so the same person may appear under
  several spellings. Counting distinct brewers will overcount.
- **Quality check results can be empty** where the source recorded nothing. Those batches
  fall out of both the pass and fail counts.

{% enddocs %}


{% docs fct_customer_guild_memberships %}

Which guilds a wizard has belonged to and when, one row per stretch of membership.

**When to use it.** Guild membership questions — who is in a guild, at what tier, and since
when. This is where a guild question starts.

**Not** for counting customers on its own, and not for spend. Bring
`fct_customer_lifetime_value` alongside for spending, but read the grain warning below
first — this is the single most common source of inflated numbers in the whole project.

**Grain.** One row per stretch of membership, not one row per wizard and not one row per
guild. A wizard who joined, left, and rejoined appears three times. A wizard in two guilds
at once appears twice.

**Watch out for:**

- **Bringing this alongside customer data multiplies the customer.** Counting wizards or
  adding up their spend afterwards inflates both, usually by 30–60%, and the result looks
  entirely plausible. Keep only rows where `is_current_membership` is true before counting
  anything — and even then a wizard in two guilds at once still appears twice.
- **`is_current_membership` is calculated against the day the data was last refreshed**, so
  a row can flip from true to false overnight with nothing in the source changing.
- **An empty `valid_to` means the membership is still open**, not that the date is missing.
  Filtering it out drops exactly the current members you probably wanted.
- **Tier is the tier recorded for that stretch of membership**, not the wizard's current
  tier. A wizard who was promoted has two rows with two different tiers, and both are
  correct.

{% enddocs %}
