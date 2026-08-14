select
    potions.potion_sku,
    potions.potion_name,
    potions.category,
    potions.base_price_copper,
    potions.base_price_gold,
    potions.potency,
    potions.shelf_life_days,
    potions.is_regulated,
    potions.introduced_at,
    coalesce(recipe_costs.recipe_ingredient_count, 0) as recipe_ingredient_count,
    coalesce(recipe_costs.recipe_unit_cost_gold, 0)::number(18, 2) as recipe_unit_cost_gold,
    coalesce(recipe_costs.uses_hazardous_ingredient, false) as uses_hazardous_ingredient
from {{ ref('stg_merlinco_potions') }} as potions
left join {{ ref('int_merlinco_potion_recipe_costs') }} as recipe_costs
    on potions.potion_sku = recipe_costs.potion_sku
