select
    nullif(trim(SUPPLIER_ID), '') as supplier_id,
    nullif(trim(SUPPLIER_NAME), '') as supplier_name,
    {{ merlinco_normalize_region('REGION') }} as region,
    try_to_number(RELIABILITY_RATING)::number(10, 2) as reliability_rating,
    try_to_date(CONTRACTED_SINCE) as contracted_since
from {{ source('merlinco_apothecaries', 'RAW_SUPPLIERS') }}
