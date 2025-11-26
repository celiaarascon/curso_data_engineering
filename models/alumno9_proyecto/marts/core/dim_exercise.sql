{{ 
    config(
        materialized="table", 
        unique_key="exercise_id",
        database='ALUMNO9_PROYECTO_GOLD'
    ) 
}}

with
    exercise_base as (
        select
            e.exercise_id,
            e.exercise_name,
            e.fk_primary_muscle_id,
            e.fk_secondary_muscle_id,
            e.fk_movement_type_id,
        from {{ ref("stg_workout_data__exercises") }} e
    )

select
    eb.exercise_id,
    eb.exercise_name,
    pm.muscle_name as primary_muscle,
    sm.muscle_name as secondary_muscle,
from exercise_base eb
left join
    {{ ref("stg_workout_data__muscle") }} pm on eb.fk_primary_muscle_id = pm.muscle_id
left join
    {{ ref("stg_workout_data__muscle") }} sm on eb.fk_secondary_muscle_id = sm.muscle_id
