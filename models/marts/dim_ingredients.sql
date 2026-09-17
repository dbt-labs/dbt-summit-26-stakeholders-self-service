-- Selected explicitly rather than `select *` so the enforced contract on this model keeps
-- its promise: an added column upstream can't silently change this model's shape.
select
    ingredient_id,
    ingredient_name,
    supplier_id,
    supplier_name,
    unit,
    unit_cost_copper,
    unit_cost_gold,
    is_hazardous,
    harvest_season
from {{ ref('int_merlinco_ingredients_enriched') }}
