with customers as (
    select * from {{ ref('stg_merlinco_customers') }}
),

orders as (
    select * from {{ ref('int_merlinco_order_financial_rollup') }}
),

order_rollup as (
    select
        customer_id,
        min(ordered_at) as first_order_at,
        max(ordered_at) as last_order_at,
        min(ordered_date) as first_order_date,
        max(ordered_date) as last_order_date,
        count(*) as order_count,
        count_if(order_status is distinct from 'cancelled') as billable_order_count,
        count_if(order_status = 'completed') as completed_order_count,
        count_if(order_status = 'returned') as returned_order_count,
        count_if(order_status = 'cancelled') as cancelled_order_count,
        count_if(order_status = 'placed') as open_order_count,
        count(distinct shop_id) as shop_count,
        sum(order_item_count) as lifetime_order_item_count,
        sum(total_quantity)::number(18, 4) as lifetime_quantity,
        sum(case when order_status is distinct from 'cancelled' then gross_revenue_gold else 0 end)::number(18, 2) as lifetime_gross_revenue_gold,
        sum(case when order_status is distinct from 'cancelled' then discount_gold else 0 end)::number(18, 2) as lifetime_discount_gold,
        sum(case when order_status is distinct from 'cancelled' then net_revenue_gold else 0 end)::number(18, 2) as lifetime_net_revenue_gold,
        sum(case when order_status = 'returned' then net_revenue_gold else 0 end)::number(18, 2) as returned_revenue_gold,
        sum(successful_payment_gold)::number(18, 2) as lifetime_collected_gold,
        sum(refunded_payment_gold)::number(18, 2) as lifetime_refunded_gold
    from orders
    group by 1
)

select
    customers.customer_id,
    customers.signed_up_at,
    customers.signed_up_date,
    customers.home_region,
    customers.favored_discipline,
    order_rollup.first_order_at,
    order_rollup.last_order_at,
    order_rollup.first_order_date,
    order_rollup.last_order_date,
    coalesce(order_rollup.order_count, 0) as order_count,
    coalesce(order_rollup.billable_order_count, 0) as billable_order_count,
    coalesce(order_rollup.completed_order_count, 0) as completed_order_count,
    coalesce(order_rollup.returned_order_count, 0) as returned_order_count,
    coalesce(order_rollup.cancelled_order_count, 0) as cancelled_order_count,
    coalesce(order_rollup.open_order_count, 0) as open_order_count,
    coalesce(order_rollup.shop_count, 0) as shop_count,
    coalesce(order_rollup.lifetime_order_item_count, 0) as lifetime_order_item_count,
    coalesce(order_rollup.lifetime_quantity, 0)::number(18, 4) as lifetime_quantity,
    coalesce(order_rollup.lifetime_gross_revenue_gold, 0)::number(18, 2) as lifetime_gross_revenue_gold,
    coalesce(order_rollup.lifetime_discount_gold, 0)::number(18, 2) as lifetime_discount_gold,
    coalesce(order_rollup.lifetime_net_revenue_gold, 0)::number(18, 2) as lifetime_net_revenue_gold,
    coalesce(order_rollup.returned_revenue_gold, 0)::number(18, 2) as returned_revenue_gold,
    coalesce(order_rollup.lifetime_collected_gold, 0)::number(18, 2) as lifetime_collected_gold,
    coalesce(order_rollup.lifetime_refunded_gold, 0)::number(18, 2) as lifetime_refunded_gold,
    (coalesce(order_rollup.lifetime_collected_gold, 0) - coalesce(order_rollup.lifetime_refunded_gold, 0))::number(18, 2) as lifetime_net_collected_gold,
    (order_rollup.lifetime_net_revenue_gold / nullif(order_rollup.billable_order_count, 0))::number(18, 2) as average_order_value_gold,
    datediff('day', customers.signed_up_date, order_rollup.first_order_date) as days_to_first_order,
    datediff('day', order_rollup.first_order_date, order_rollup.last_order_date) as customer_lifespan_days,
    datediff('day', order_rollup.last_order_date, current_date()) as days_since_last_order,
    coalesce(order_rollup.billable_order_count, 0) > 0 as has_ordered,
    coalesce(order_rollup.billable_order_count, 0) > 1 as is_repeat_customer
from customers
left join order_rollup
    on customers.customer_id = order_rollup.customer_id
