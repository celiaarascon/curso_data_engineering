{{
    config(
        materialized="view",
        database="ALUMNO9_PROYECTO_SILVER",
        schema="staging_workout_data"
    )
}}

with
    src_exercises as (select * from {{ source("workout_data", "exercises_raw") }}),

    cleaned_exercises as (
        select
            {{ dbt_utils.generate_surrogate_key(["exercise_id"]) }} as exercise_sk,
            nullif(trim(exercise_id), '') as exercise_id,
            nullif(trim(exercise_name), '') as exercise_name,
            primary_muscle,
            secondary_muscle,
            {{ dbt_utils.generate_surrogate_key(["movement_type"]) }} as fk_movement_type_id,
            {{ dbt_utils.generate_surrogate_key(["equipment"]) }} as fk_equipment_id
        from src_exercises
    )

select *
from cleaned_exercises