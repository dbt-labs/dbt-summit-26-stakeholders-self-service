select
    nullif(trim(POTION_SKU), '') as potion_sku,
    nullif(trim(INGREDIENT_ID), '') as ingredient_id,
    try_to_number(QUANTITY)::number(18, 4) as ingredient_quantity,
    lower(nullif(trim(UNIT), '')) as unit
from {{ source('merlinco_apothecaries', 'RAW_POTION_INGREDIENTS') }}
