select
    nullif(trim(MEMBERSHIP_ID), '') as membership_id,
    nullif(trim(CUSTOMER_ID), '') as customer_id,
    nullif(trim(GUILD_ID), '') as guild_id,
    lower(nullif(trim(TIER), '')) as membership_tier,
    try_to_date(VALID_FROM) as valid_from,
    try_to_date(VALID_TO) as valid_to
from {{ source('merlinco_apothecaries', 'RAW_GUILD_MEMBERSHIPS') }}
