select 'fct_orders' as model_name, order_id as record_id
from {{ ref('fct_orders') }}
where gross_revenue_gold < 0
   or discount_gold < 0
   or net_revenue_gold < 0
   or successful_payment_gold < 0

union all

select 'fct_order_items' as model_name, order_item_id as record_id
from {{ ref('fct_order_items') }}
where quantity < 0
   or line_gross_gold < 0
   or allocated_discount_gold < 0
   or line_net_gold < 0

union all

select 'fct_payments' as model_name, payment_id as record_id
from {{ ref('fct_payments') }}
where amount_gold < 0

union all

select 'fct_brew_events' as model_name, brew_id as record_id
from {{ ref('fct_brew_events') }}
where batch_size < 0
   or brew_duration_minutes < 0
   or estimated_batch_cost_gold < 0
