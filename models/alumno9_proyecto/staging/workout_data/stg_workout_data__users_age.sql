{{
    config(
        materialized="view",
        database="ALUMNO9_PROYECTO_SILVER"
    )
}}

with
    src_users as (select * from {{ source("workout_data", "users_raw") }}),

    distinct_age_groups as (
        select distinct
            case
                when cast(age as integer) < 25
                then '18-24'
                when cast(age as integer) < 35
                then '25-34'
                when cast(age as integer) < 45
                then '35-44'
                else '45+'
            end as age_group
        from src_users
        where age is not null
    ),

    prepared_age as (
        select
            {{ dbt_utils.generate_surrogate_key(["age_group"]) }} as age_id,
            age_group,
            case
                when age_group = '18-24'
                then 'Young adults'
                when age_group = '25-34'
                then 'Adults'
                when age_group = '35-44'
                then 'Middle-aged adults'
                when age_group = '45+'
                then 'Senior adults'
                else 'Unknown'
            end as age_group_description
        from distinct_age_groups
    )

select *
from prepared_age
