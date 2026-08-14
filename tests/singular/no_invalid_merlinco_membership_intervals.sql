select membership_id
from {{ ref('fct_customer_guild_memberships') }}
where valid_to is not null
  and valid_to < valid_from
