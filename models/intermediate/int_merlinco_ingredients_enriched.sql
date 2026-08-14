select
    ingredients.ingredient_id,
    ingredients.ingredient_name,
    ingredients.supplier_id,
    suppliers.supplier_name,
    ingredients.unit,
    ingredients.unit_cost_copper,
    ingredients.unit_cost_gold,
    ingredients.is_hazardous,
    ingredients.harvest_season
from {{ ref('stg_merlinco_ingredients') }} as ingredients
left join {{ ref('stg_merlinco_suppliers') }} as suppliers
    on ingredients.supplier_id = suppliers.supplier_id
