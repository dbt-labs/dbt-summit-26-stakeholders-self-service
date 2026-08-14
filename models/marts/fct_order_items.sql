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
    line_net_gold
from {{ ref('int_merlinco_order_items_enriched') }}
