-- "Price is above zero" cannot be written with the four generic tests available in this
-- project (unique, not_null, accepted_values, relationships) and no test packages installed.
-- A singular test is how you express it without reaching for a dependency.
select
    order_item_id,
    unit_price_gold,
    quantity
from {{ ref('fct_order_items') }}
where unit_price_gold <= 0
   or quantity <= 0
