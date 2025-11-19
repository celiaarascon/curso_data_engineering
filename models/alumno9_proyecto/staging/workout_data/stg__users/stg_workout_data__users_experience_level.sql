{{ config(materialized="view", database="ALUMNO9_PROYECTO_SILVER", schema="staging_workout_data") }}

with
    src_users as (select * from {{ source("workout_data", "users_raw") }}),

    distinct_experience as (
        select distinct
            case
                when lower(nullif(trim(experience_level), '')) = 'beginner'
                then 'beginner'
                when lower(nullif(trim(experience_level), '')) = 'intermediate'
                then 'intermediate'
                when lower(nullif(trim(experience_level), '')) = 'advanced'
                then 'advanced'
                else 'unknown'
            end as experience_level
        from src_users
        where experience_level is not null
    ),

    prepared_experience as (
        select
            {{ dbt_utils.generate_surrogate_key(["experience_level"]) }}
            as experience_level_id,
            experience_level,
            initcap(experience_level) as experience_level_description
        from distinct_experience
    )

select *
from prepared_experience
