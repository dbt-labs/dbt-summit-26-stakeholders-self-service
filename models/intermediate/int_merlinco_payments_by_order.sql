select
    order_id,
    min(paid_at) as first_paid_at,
    max(paid_at) as last_paid_at,
    count(*) as payment_attempt_count,
    count_if(payment_status = 'success') as successful_payment_count,
    count_if(payment_status = 'failed') as failed_payment_count,
    count_if(payment_status = 'refunded') as refunded_payment_count,
    coalesce(sum(case when payment_status = 'success' then amount_gold else 0 end), 0)::number(18, 2) as successful_payment_gold,
    coalesce(sum(case when payment_status = 'failed' then amount_gold else 0 end), 0)::number(18, 2) as failed_payment_gold,
    coalesce(sum(case when payment_status = 'refunded' then amount_gold else 0 end), 0)::number(18, 2) as refunded_payment_gold
from {{ ref('stg_merlinco_payments') }}
group by 1
