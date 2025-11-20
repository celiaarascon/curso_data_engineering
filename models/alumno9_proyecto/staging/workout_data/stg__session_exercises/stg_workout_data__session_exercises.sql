{{ config(materialized="view", database="ALUMNO9_PROYECTO_SILVER") }}

with
    src_session_exercises as (
        select * from {{ source("workout_data", "session_exercises_raw") }}
    ),

    cleaned_session_exercises as (
        select
            {{ dbt_utils.generate_surrogate_key(["entry_id"]) }} as entry_sk,
            nullif(trim(entry_id), '') as entry_id,
            nullif(trim(session_id), '') as session_id,
            nullif(trim(exercise_id), '') as exercise_id,
            try_cast(sets as integer) as sets,
            try_cast(reps as integer) as reps,
            try_cast(weight_kg as decimal(8, 2)) as weight_kg,
            try_cast(sets as integer)
            * try_cast(reps as integer)
            * try_cast(weight_kg as decimal(8, 2)) as volume_kg,
            try_cast(estimated_1rm as decimal(8, 2)) as estimated_1_rep_max
        from src_session_exercises
        where
            sets is not null
            and reps is not null
            and weight_kg is not null
            and estimated_1rm is not null
    )

select *
from cleaned_session_exercises
