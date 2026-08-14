select
    nullif(trim(GUILD_ID), '') as guild_id,
    nullif(trim(GUILD_NAME), '') as guild_name,
    try_to_number(FOUNDED_YEAR)::integer as founded_year
from {{ source('merlinco_apothecaries', 'RAW_GUILDS') }}
