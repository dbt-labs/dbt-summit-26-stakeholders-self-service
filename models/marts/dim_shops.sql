select
    shop_id,
    shop_name,
    city,
    region,
    opened_at
from {{ ref('stg_merlinco_shops') }}
