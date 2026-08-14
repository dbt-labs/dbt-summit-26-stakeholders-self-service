select
    supplier_id,
    supplier_name,
    region,
    reliability_rating,
    contracted_since
from {{ ref('stg_merlinco_suppliers') }}
