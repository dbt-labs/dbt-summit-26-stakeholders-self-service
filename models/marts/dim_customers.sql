with customers as (
    select * from {{ ref('stg_merlinco_customers') }}
),

current_memberships as (
    select
        customer_id,
        count(*) as current_guild_count,
        min(valid_from) as first_current_membership_started_at
    from {{ ref('int_merlinco_current_guild_memberships') }}
    group by 1
)

select
    customers.customer_id,
    customers.full_name,
    customers.email,
    customers.home_region,
    customers.signed_up_at,
    customers.signed_up_date,
    customers.birth_year,
    customers.favored_discipline,
    coalesce(current_memberships.current_guild_count, 0) as current_guild_count,
    current_memberships.first_current_membership_started_at
from customers
left join current_memberships
    on customers.customer_id = current_memberships.customer_id
