{% docs fct_order_items %}

<!--
LAB 1 (LESSON 2) STARTING POINT.

This is what most projects actually ship: technically accurate, useless to a
stakeholder, and useless to an AI assistant trying to answer a question about it.

Replace it by answering the four questions in docs/STAKEHOLDER_DOC_PATTERNS.md:
what is this, when should I use it, what's the grain, what should I watch out for.

Keep the original line at the bottom under "Before:" so the difference is visible
in the catalog during the debrief.
-->

Order item fact at one row per order line with allocated order discounts.

{% enddocs %}


{% docs dim_potions %}

<!-- LAB 1 STARTING POINT — same deal. -->

Potion dimension at one row per potion SKU, with recipe cost fields from the intermediate layer.

{% enddocs %}


{% docs dim_shops %}

<!-- LAB 1 STARTING POINT — same deal. -->

Shop dimension at one row per shop.

{% enddocs %}


{% docs dim_customers %}

<!-- LAB 1 STARTING POINT — same deal. -->

Customer dimension at one row per customer. Includes home region and signup date.

{% enddocs %}


{% docs __worked_example %}

<!--
Reference implementation. Reveal at the Lesson 2 debrief.

Every caveat below is true of this project's data — check them against the models
before teaching them. A fabricated caveat is worse than no caveat: attendees copy
the exemplar, and a plausible-but-false warning is exactly the failure mode this
lesson exists to prevent.
-->

Every potion sold, one row per line on a customer's order.

**Use this for** revenue and unit-volume reporting by shop, region, potion, and
channel. **Do not use this for** inventory on hand — brewing is not netted
against sales here; use `fct_brew_events`.

**Grain:** one row per order line. An order containing three different potions
appears as three rows. Summing revenue across orders is safe; summing it after
joining to guild memberships is not, because a customer can hold more than one
membership at a time.

**Watch out for:**

- Returned and cancelled orders are included, at full line value. Nothing here is
  netted out — filter on `order_status` (`completed`, `returned`, `cancelled`,
  `placed`) or you will overstate revenue.
- Marketplace orders arrive up to 48 hours late. The current day is always
  incomplete — do not use it for day-over-day comparisons.
- Prices are carried in both copper and gold. Gold is the reporting standard;
  copper is retained for reconciliation against the POS system.

{% enddocs %}
