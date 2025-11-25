{{
    config(
        materialized="view",
        database="ALUMNO9_PROYECTO_SILVER"
    )
}}

with
    src_exercises as (select * from {{ source("workout_data", "exercises_raw") }}),

    distinct_movement_types as (
        select distinct
            case
                when lower(nullif(trim(movement_type), '')) = 'compound'
                then 'compound'
                when lower(nullif(trim(movement_type), '')) = 'isolation'
                then 'isolation'
                else 'unknown'
            end as movement_type
        from src_exercises
        where movement_type is not null
    ),

    prepared_movement_types as (
        select
            {{ dbt_utils.generate_surrogate_key(["movement_type"]) }}
            as movement_type_id,
            initcap(movement_type) as movement_type_name
        from distinct_movement_types
    )

select *
from prepared_movement_types
