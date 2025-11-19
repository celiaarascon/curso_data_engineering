{{ config(materialized="view", database="ALUMNO9_PROYECTO_SILVER", schema="staging_workout_data") }}

with
    src_users as (select * from {{ source("workout_data", "users_raw") }}),

    distinct_sex as (
        select distinct
            case
                when upper(nullif(trim(sex), '')) = 'M'
                then 'M'
                when upper(nullif(trim(sex), '')) = 'F'
                then 'F'
                else 'Unknown'
            end as sex
        from src_users
        where sex is not null
    ),

    prepared_sex as (
        select
            {{ dbt_utils.generate_surrogate_key(["sex"]) }} as sex_id,
            sex,
            case
                when sex = 'M' then 'Male' when sex = 'F' then 'Female' else 'Unknown'
            end as sex_description
        from distinct_sex
    )

select *
from prepared_sex
