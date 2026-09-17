-- Selected explicitly rather than `select *` so the enforced contract on this model keeps
-- its promise: an added column upstream can't silently change this model's shape.
select
    membership_id,
    customer_id,
    guild_id,
    membership_tier,
    valid_from,
    valid_to,
    is_current_membership
from {{ ref('int_merlinco_customer_guild_memberships') }}
