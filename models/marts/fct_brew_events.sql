select
    brew_id,
    potion_sku,
    shop_id,
    cauldron_id,
    brewed_at,
    brewed_date,
    batch_size,
    brew_duration_minutes,
    quality_check,
    brewer_name,
    potion_category,
    recipe_ingredient_count,
    recipe_unit_cost_gold,
    estimated_batch_cost_gold,
    passed_quality_check,
    sellable_units_brewed
from {{ ref('int_merlinco_brew_events_enriched') }}
