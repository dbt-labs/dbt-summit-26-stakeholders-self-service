-- A wizard cannot buy before they sign up. Nulls are excluded deliberately: a null
-- first_order_date means "never ordered", which is expected and documented, not a failure.
select
    customer_id,
    signed_up_date,
    first_order_date
from {{ ref('fct_customer_lifetime_value') }}
where first_order_date is not null
  and signed_up_date is not null
  and first_order_date < signed_up_date
