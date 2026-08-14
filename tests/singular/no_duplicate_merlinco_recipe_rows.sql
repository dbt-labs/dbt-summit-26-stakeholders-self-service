select
    potion_sku,
    ingredient_id,
    count(*) as duplicate_count
from {{ ref('stg_merlinco_potion_ingredients') }}
group by 1, 2
having count(*) > 1
