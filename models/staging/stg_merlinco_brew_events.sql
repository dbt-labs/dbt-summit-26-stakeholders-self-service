select
    nullif(trim(BREW_ID), '') as brew_id,
    nullif(trim(POTION_SKU), '') as potion_sku,
    nullif(trim(SHOP_ID), '') as shop_id,
    nullif(trim(CAULDRON_ID), '') as cauldron_id,
    try_to_timestamp_ntz(BREWED_AT) as brewed_at,
    try_to_date(BREWED_AT) as brewed_date,
    try_to_number(BATCH_SIZE)::number(18, 4) as batch_size,
    try_to_number(BREW_DURATION_MINUTES)::number(18, 4) as brew_duration_minutes,
    lower(nullif(trim(QUALITY_CHECK), '')) as quality_check,
    nullif(trim(BREWER_NAME), '') as brewer_name
from {{ source('merlinco_apothecaries', 'RAW_BREW_EVENTS') }}
