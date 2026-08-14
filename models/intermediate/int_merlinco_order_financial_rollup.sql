with orders as (
    select * from {{ ref('stg_merlinco_orders') }}
),

item_rollup as (
    select
        order_id,
        count(*) as order_item_count,
        sum(quantity)::number(18, 4) as total_quantity,
        sum(line_gross_gold)::number(18, 2) as gross_revenue_gold,
        sum(allocated_discount_gold)::number(18, 2) as discount_gold,
        sum(line_net_gold)::number(18, 2) as net_revenue_gold
    from {{ ref('int_merlinco_order_items_enriched') }}
    group by 1
),

payments as (
    select * from {{ ref('int_merlinco_payments_by_order') }}
)

select
    orders.order_id,
    orders.customer_id,
    orders.shop_id,
    orders.ordered_at,
    orders.ordered_date,
    orders.order_status,
    orders.order_channel,
    coalesce(item_rollup.order_item_count, 0) as order_item_count,
    coalesce(item_rollup.total_quantity, 0)::number(18, 4) as total_quantity,
    coalesce(item_rollup.gross_revenue_gold, 0)::number(18, 2) as gross_revenue_gold,
    coalesce(item_rollup.discount_gold, orders.discount_gold, 0)::number(18, 2) as discount_gold,
    coalesce(item_rollup.net_revenue_gold, -orders.discount_gold, 0)::number(18, 2) as net_revenue_gold,
    payments.first_paid_at,
    payments.last_paid_at,
    coalesce(payments.payment_attempt_count, 0) as payment_attempt_count,
    coalesce(payments.successful_payment_count, 0) as successful_payment_count,
    coalesce(payments.failed_payment_count, 0) as failed_payment_count,
    coalesce(payments.refunded_payment_count, 0) as refunded_payment_count,
    coalesce(payments.successful_payment_gold, 0)::number(18, 2) as successful_payment_gold,
    coalesce(payments.failed_payment_gold, 0)::number(18, 2) as failed_payment_gold,
    coalesce(payments.refunded_payment_gold, 0)::number(18, 2) as refunded_payment_gold
from orders
left join item_rollup
    on orders.order_id = item_rollup.order_id
left join payments
    on orders.order_id = payments.order_id
