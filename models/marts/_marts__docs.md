<!--
LAB 1 (LESSON 2) TARGETS.

Everything inside a docs block below is compiled into the model's `description`
and shipped to dbt Catalog, the Semantic Layer, and any AI assistant reading
this project — HTML comments included. Keep lab instructions out here, above the
blocks, where dbt ignores them. (Don't write a docs tag inside this comment
either; dbt reads the tag, not the comment around it, and will swallow the
block below.)

The prose below is the "before" state: technically accurate, useless to a
stakeholder. Rewriting it is Lab 1. See labs/01-document-for-humans-and-ai/.

fct_customer_lifetime_value is the block every attendee rewrites. The other four
are the same "before" state on other models — worked examples, and stretch
targets for anyone who finishes early.
-->

{% docs fct_customer_lifetime_value %}

Customer lifetime value fact at one row per customer, aggregated from the order financial rollup in the intermediate layer.

{% enddocs %}


{% docs fct_order_items %}

Order item fact at one row per order line with allocated order discounts.

{% enddocs %}


{% docs dim_potions %}

Potion dimension at one row per potion SKU, with recipe cost fields from the intermediate layer.

{% enddocs %}


{% docs dim_shops %}

Shop dimension at one row per shop.

{% enddocs %}


{% docs dim_customers %}

Customer dimension at one row per customer. Includes home region and signup date.

{% enddocs %}
