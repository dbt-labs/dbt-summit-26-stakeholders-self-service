select
    nullif(trim(SHOP_ID), '') as shop_id,
    nullif(trim(SHOP_NAME), '') as shop_name,
    nullif(trim(CITY), '') as city,
    {{ merlinco_normalize_region('REGION') }} as region,
    try_to_date(OPENED_AT) as opened_at
from {{ source('merlinco_apothecaries', 'RAW_SHOPS') }}
