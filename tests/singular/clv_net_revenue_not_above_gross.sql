-- Discounts can only reduce revenue, so net above gross means the discount aggregation
-- has drifted. Tolerance of a copper absorbs rounding in the line-level allocation.
select
    customer_id,
    lifetime_gross_revenue,
    lifetime_net_revenue
from {{ ref('fct_customer_lifetime_value') }}
where lifetime_net_revenue > lifetime_gross_revenue + 0.01
