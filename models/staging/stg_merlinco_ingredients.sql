select
    nullif(trim(INGREDIENT_ID), '') as ingredient_id,
    nullif(trim(INGREDIENT_NAME), '') as ingredient_name,
    nullif(trim(SUPPLIER_ID), '') as supplier_id,
    lower(nullif(trim(UNIT), '')) as unit,
    try_to_number(UNIT_COST_COPPER)::number(18, 2) as unit_cost_copper,
    {{ merlinco_copper_to_gold('UNIT_COST_COPPER') }}::number(18, 2) as unit_cost_gold,
    {{ merlinco_normalize_boolean('IS_HAZARDOUS') }} as is_hazardous,
    lower(nullif(trim(HARVEST_SEASON), '')) as harvest_season
from {{ source('merlinco_apothecaries', 'RAW_INGREDIENTS') }}
