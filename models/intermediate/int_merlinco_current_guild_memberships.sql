select
    membership_id,
    customer_id,
    guild_id,
    membership_tier,
    valid_from,
    valid_to
from {{ ref('stg_merlinco_guild_memberships') }}
where valid_from <= current_date
  and (valid_to is null or valid_to >= current_date)
