-- tests/activation_data_validation.sql
{{ config(severity = 'error') }}

-- Test para verificar que existe activación y no es nula
WITH activation_check AS (
    SELECT 
        id,
        exercise_id,
        muscle,
        activation_score
    FROM {{ source('workout_data', 'muscle_activation_estimate_raw') }}
    WHERE 
        activation_score IS NULL 
        OR TRY_CAST(activation_score AS FLOAT) <= 0
        OR muscle IS NULL
        OR exercise_id IS NULL
)

SELECT *
FROM activation_check