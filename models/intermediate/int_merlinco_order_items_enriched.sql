with order_items as (
    select * from {{ ref('stg_merlinco_order_items') }}
),

orders as (
    select * from {{ ref('stg_merlinco_orders') }}
),

potions as (
    select * from {{ ref('stg_merlinco_potions') }}
),

enriched as (
    select
        order_items.order_item_id,
        order_items.order_id,
        orders.customer_id,
        orders.shop_id,
        order_items.potion_sku,
        orders.ordered_at,
        orders.ordered_date,
        orders.order_status,
        orders.order_channel,
        potions.category as potion_category,
        order_items.quantity,
        order_items.unit_price_copper,
        order_items.unit_price_gold,
        orders.discount_gold as order_discount_gold,
        (order_items.quantity * order_items.unit_price_gold)::number(18, 2) as line_gross_gold,
        sum(order_items.quantity * order_items.unit_price_gold) over (
            partition by order_items.order_id
        )::number(18, 2) as order_gross_gold
    from order_items
    left join orders
        on order_items.order_id = orders.order_id
    left join potions
        on order_items.potion_sku = potions.potion_sku
),

allocated as (
    select
        *,
        case
            when order_gross_gold > 0
                then (order_discount_gold * line_gross_gold / order_gross_gold)::number(18, 2)
            else 0::number(18, 2)
        end as rounded_allocated_discount_gold,
        row_number() over (
            partition by order_id
            order by order_item_id desc
        ) as reverse_line_number
    from enriched
),

final_allocations as (
    select
        *,
        case
            when reverse_line_number = 1 then (
                order_discount_gold
                - (
                    sum(rounded_allocated_discount_gold) over (partition by order_id)
                    - rounded_allocated_discount_gold
                )
            )::number(18, 2)
            else rounded_allocated_discount_gold
        end as allocated_discount_gold
    from allocated
)

select
    order_item_id,
    order_id,
    customer_id,
    shop_id,
    potion_sku,
    ordered_at,
    ordered_date,
    order_status,
    order_channel,
    potion_category,
    quantity,
    unit_price_copper,
    unit_price_gold,
    line_gross_gold,
    allocated_discount_gold,
    (line_gross_gold - allocated_discount_gold)::number(18, 2) as line_net_gold
from final_allocations
