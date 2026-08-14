with recipe_lines as (
    select * from {{ ref('stg_merlinco_potion_ingredients') }}
),

ingredients as (
    select * from {{ ref('stg_merlinco_ingredients') }}
)

select
    recipe_lines.potion_sku,
    count(*) as recipe_ingredient_count,
    sum(recipe_lines.ingredient_quantity * ingredients.unit_cost_gold)::number(18, 2) as recipe_unit_cost_gold,
    max(case when ingredients.is_hazardous then 1 else 0 end)::boolean as uses_hazardous_ingredient
from recipe_lines
left join ingredients
    on recipe_lines.ingredient_id = ingredients.ingredient_id
group by 1
