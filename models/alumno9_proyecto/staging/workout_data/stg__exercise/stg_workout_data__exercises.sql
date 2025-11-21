{{ config(materialized="view", database="ALUMNO9_PROYECTO_SILVER") }}

with
    src_exercises as (select * from {{ source("workout_data", "exercises_raw") }}),

    cleaned_exercises as (
        select
            nullif(trim(exercise_id), '') as exercise_id,
            nullif(trim(exercise_name), '') as exercise_name,
            {{ dbt_utils.generate_surrogate_key(["primary_muscle"]) }}
            as fk_primary_muscle_id,
            case
                when nullif(trim(secondary_muscle), '') is not null
                then {{ dbt_utils.generate_surrogate_key(["secondary_muscle"]) }}
                else null
            end as fk_secondary_muscle_id,
            {{ dbt_utils.generate_surrogate_key(["movement_type"]) }}
            as fk_movement_type_id,
            {{ dbt_utils.generate_surrogate_key(["equipment"]) }} as fk_equipment_id
        from src_exercises
    )

select *
from cleaned_exercises
