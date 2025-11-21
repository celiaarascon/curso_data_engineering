{{
    config(
        materialized='incremental',
        unique_key='entry_id'
    )
}}

WITH exercise_data AS (
    SELECT
        se.entry_id,
        se.session_id,
        se.exercise_id,
        se.sets,
        se.reps,
        se.weight_kg,
        se.volume_kg AS volumen_kg,
        se.estimated_1_rep_max AS estimated_1rm,
        s.user_id,
        s.duration_minutes,
        se_subjective.subjective_effort,
        s.fk_session_date_id  -- Usamos directamente el session_date_id
    FROM {{ ref('stg_workout_data__session_exercises') }} se
    INNER JOIN {{ ref('stg_workout_data__sessions') }} s 
        ON se.session_id = s.session_id
    LEFT JOIN {{ ref('stg_workout_data__session_subjective_effort') }} se_subjective
        ON s.fk_subjective_effort_id = se_subjective.subjective_effort_id
),

final AS (
    SELECT
        ex.entry_id,
        ex.user_id AS fk_user_id,
        ex.exercise_id AS fk_exercise_id,
        ex.session_id AS fk_session_id,
        ex.fk_session_date_id AS fk_date_id,  -- Usamos directamente el session_date_id
        ex.sets,
        ex.reps,
        ex.weight_kg,
        ex.volumen_kg,
        ex.estimated_1rm,
        ex.duration_minutes AS duration_min,
        ex.subjective_effort
    FROM exercise_data ex
    WHERE ex.fk_session_date_id IS NOT NULL
)

SELECT *
FROM final

{% if is_incremental() %}
    WHERE entry_id NOT IN (SELECT entry_id FROM {{ this }})
{% endif %}