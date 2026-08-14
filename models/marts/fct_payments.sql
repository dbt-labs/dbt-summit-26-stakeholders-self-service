select
    payment_id,
    order_id,
    payment_method,
    amount_copper,
    amount_gold,
    payment_status,
    paid_at,
    paid_date
from {{ ref('stg_merlinco_payments') }}
