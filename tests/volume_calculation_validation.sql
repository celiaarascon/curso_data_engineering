{{ config(severity="error") }}

-- Test singular para comprobar que volume_kg esta bien calculado
with
    volume_calculation as (
        select
            entry_id,
            session_id,
            exercise_id,
            sets,
            reps,
            weight_kg,
            volume_kg,
            try_cast(sets as float) as sets_float,
            try_cast(reps as float) as reps_float,
            try_cast(weight_kg as float) as weight_kg_float,
            try_cast(volume_kg as float) as volume_kg_float,
            try_cast(sets as float)
            * try_cast(reps as float)
            * try_cast(weight_kg as float) as calculated_volume,
            abs(
                try_cast(volume_kg as float) - (
                    try_cast(sets as float)
                    * try_cast(reps as float)
                    * try_cast(weight_kg as float)
                )
            ) as difference
        from {{ source("workout_data", "stg_workout_data__session_exercises") }}
        where
            sets is not null
            and reps is not null
            and weight_kg is not null
            and volume_kg is not null
    )

select
    entry_id,
    session_id,
    exercise_id,
    sets,
    reps,
    weight_kg,
    volume_kg,
    sets_float,
    reps_float,
    weight_kg_float,
    volume_kg_float,
    calculated_volume,
    difference
from volume_calculation
where difference > 0.01
