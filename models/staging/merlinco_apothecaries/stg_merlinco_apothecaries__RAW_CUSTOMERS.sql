with 

source as (

    select * from {{ source('merlinco_apothecaries', 'RAW_CUSTOMERS') }}

),

renamed as (

    select
        customer_id,
        full_name,
        email,
        home_region,
        signed_up_at,
        birth_year,
        favored_discipline

    from source

)

select * from renamed