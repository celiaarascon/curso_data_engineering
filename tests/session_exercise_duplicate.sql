{{ config(severity = 'error') }}

-- Test para verificar duplicados en session_exercises_raw
WITH duplicates AS (
    SELECT 
        session_id,
        exercise_id,
        sets,
        reps,
        weight_kg,
        COUNT(*) as record_count
    FROM {{ source('workout_data', 'session_exercises_raw') }}
    GROUP BY session_id, exercise_id, sets, reps, weight_kg
    HAVING COUNT(*) > 1
)

SELECT *
FROM duplicates