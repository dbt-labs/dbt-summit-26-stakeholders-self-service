select order_id
from {{ ref('fct_orders') }}
where abs(net_revenue_gold - (gross_revenue_gold - discount_gold)) > 0.01
