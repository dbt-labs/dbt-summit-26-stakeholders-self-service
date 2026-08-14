select 'orders_to_customers' as check_name, order_id as record_id
from {{ ref('fct_orders') }} as orders
left join {{ ref('dim_customers') }} as customers
    on orders.customer_id = customers.customer_id
where customers.customer_id is null

union all

select 'order_items_to_orders' as check_name, order_item_id as record_id
from {{ ref('fct_order_items') }} as order_items
left join {{ ref('fct_orders') }} as orders
    on order_items.order_id = orders.order_id
where orders.order_id is null

union all

select 'payments_to_orders' as check_name, payment_id as record_id
from {{ ref('fct_payments') }} as payments
left join {{ ref('fct_orders') }} as orders
    on payments.order_id = orders.order_id
where orders.order_id is null

union all

select 'brews_to_potions' as check_name, brew_id as record_id
from {{ ref('fct_brew_events') }} as brews
left join {{ ref('dim_potions') }} as potions
    on brews.potion_sku = potions.potion_sku
where potions.potion_sku is null
