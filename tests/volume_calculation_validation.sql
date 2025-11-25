{{ config(severity = 'error') }}

-- Test singular para comprobar que volume_kg esta bien calculado
WITH volume_calculation AS (
    SELECT 
        entry_id,
        session_id,
        exercise_id,
        sets,
        reps,
        weight_kg,
        volume_kg,
        TRY_CAST(sets AS FLOAT) as sets_float,
        TRY_CAST(reps AS FLOAT) as reps_float,
        TRY_CAST(weight_kg AS FLOAT) as weight_kg_float,
        TRY_CAST(volume_kg AS FLOAT) as volume_kg_float,
        TRY_CAST(sets AS FLOAT) * TRY_CAST(reps AS FLOAT) * TRY_CAST(weight_kg AS FLOAT) as calculated_volume,
        ABS(TRY_CAST(volume_kg AS FLOAT) - (TRY_CAST(sets AS FLOAT) * TRY_CAST(reps AS FLOAT) * TRY_CAST(weight_kg AS FLOAT))) as difference
    FROM {{ source('workout_data', 'stg_workout_data__session_exercises') }}
    WHERE 
        sets IS NOT NULL 
        AND reps IS NOT NULL 
        AND weight_kg IS NOT NULL 
        AND volume_kg IS NOT NULL
)

SELECT 
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
FROM volume_calculation
WHERE difference > 0.01