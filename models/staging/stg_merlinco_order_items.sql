select
    nullif(trim(ORDER_ITEM_ID), '') as order_item_id,
    nullif(trim(ORDER_ID), '') as order_id,
    nullif(trim(POTION_SKU), '') as potion_sku,
    try_to_number(QUANTITY)::number(18, 4) as quantity,
    try_to_number(UNIT_PRICE_COPPER)::number(18, 2) as unit_price_copper,
    {{ merlinco_copper_to_gold('UNIT_PRICE_COPPER') }}::number(18, 2) as unit_price_gold
from {{ source('merlinco_apothecaries', 'RAW_ORDER_ITEMS') }}
