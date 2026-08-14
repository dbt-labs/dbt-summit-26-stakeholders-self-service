select
    nullif(trim(ORDER_ID), '') as order_id,
    nullif(trim(CUSTOMER_ID), '') as customer_id,
    nullif(trim(SHOP_ID), '') as shop_id,
    try_to_timestamp_ntz(ORDERED_AT) as ordered_at,
    try_to_date(ORDERED_AT) as ordered_date,
    lower(nullif(trim(STATUS), '')) as order_status,
    lower(nullif(trim(CHANNEL), '')) as order_channel,
    coalesce(try_to_number(DISCOUNT_COPPER), 0)::number(18, 2) as discount_copper,
    coalesce({{ merlinco_copper_to_gold('DISCOUNT_COPPER') }}, 0)::number(18, 2) as discount_gold
from {{ source('merlinco_apothecaries', 'RAW_ORDERS') }}
