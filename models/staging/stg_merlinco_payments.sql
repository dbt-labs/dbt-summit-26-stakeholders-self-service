select
    nullif(trim(PAYMENT_ID), '') as payment_id,
    nullif(trim(ORDER_ID), '') as order_id,
    lower(nullif(trim(METHOD), '')) as payment_method,
    try_to_number(AMOUNT_COPPER)::number(18, 2) as amount_copper,
    {{ merlinco_copper_to_gold('AMOUNT_COPPER') }}::number(18, 2) as amount_gold,
    lower(nullif(trim(STATUS), '')) as payment_status,
    try_to_timestamp_ntz(PAID_AT) as paid_at,
    try_to_date(PAID_AT) as paid_date
from {{ source('merlinco_apothecaries', 'RAW_PAYMENTS') }}
