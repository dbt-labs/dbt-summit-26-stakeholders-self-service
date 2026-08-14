select
    nullif(trim(POTION_SKU), '') as potion_sku,
    nullif(trim(POTION_NAME), '') as potion_name,
    lower(nullif(trim(CATEGORY), '')) as category,
    try_to_number(BASE_PRICE_COPPER)::number(18, 2) as base_price_copper,
    {{ merlinco_copper_to_gold('BASE_PRICE_COPPER') }}::number(18, 2) as base_price_gold,
    try_to_number(POTENCY)::number(10, 2) as potency,
    try_to_number(SHELF_LIFE_DAYS)::integer as shelf_life_days,
    {{ merlinco_normalize_boolean('IS_REGULATED') }} as is_regulated,
    try_to_date(INTRODUCED_AT) as introduced_at
from {{ source('merlinco_apothecaries', 'RAW_POTIONS') }}
