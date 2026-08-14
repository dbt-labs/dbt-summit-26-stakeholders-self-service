with brew_events as (
    select * from {{ ref('stg_merlinco_brew_events') }}
),

potions as (
    select * from {{ ref('stg_merlinco_potions') }}
),

recipe_costs as (
    select * from {{ ref('int_merlinco_potion_recipe_costs') }}
)

select
    brew_events.brew_id,
    brew_events.potion_sku,
    brew_events.shop_id,
    brew_events.cauldron_id,
    brew_events.brewed_at,
    brew_events.brewed_date,
    brew_events.batch_size,
    brew_events.brew_duration_minutes,
    brew_events.quality_check,
    brew_events.brewer_name,
    potions.category as potion_category,
    coalesce(recipe_costs.recipe_ingredient_count, 0) as recipe_ingredient_count,
    coalesce(recipe_costs.recipe_unit_cost_gold, 0)::number(18, 2) as recipe_unit_cost_gold,
    (brew_events.batch_size * coalesce(recipe_costs.recipe_unit_cost_gold, 0))::number(18, 2) as estimated_batch_cost_gold,
    brew_events.quality_check = 'pass' as passed_quality_check,
    case
        when brew_events.quality_check = 'pass' then brew_events.batch_size
        else 0
    end::number(18, 4) as sellable_units_brewed
from brew_events
left join potions
    on brew_events.potion_sku = potions.potion_sku
left join recipe_costs
    on brew_events.potion_sku = recipe_costs.potion_sku
