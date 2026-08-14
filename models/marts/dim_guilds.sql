select
    guild_id,
    guild_name,
    founded_year
from {{ ref('stg_merlinco_guilds') }}
