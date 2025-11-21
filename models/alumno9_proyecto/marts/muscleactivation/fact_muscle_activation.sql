{{
    config(
        materialized='incremental',
        unique_key='muscle_activation_estimate_sk'
    )
}}

WITH muscle_activation_base AS (
    SELECT
        ma.muscle_activation_sk AS muscle_activation_estimate_sk,
        ma.exercise_id,
        ma.fk_muscle_id,
        ma.activation_score,
        se.entry_id AS fk_entry_id,
        se.session_id,
        s.user_id,
        s.fk_session_date_id
    FROM {{ ref('stg_workout_data__muscle_activation_estimate') }} ma
    INNER JOIN {{ ref('stg_workout_data__session_exercises') }} se 
        ON ma.exercise_id = se.exercise_id
    INNER JOIN {{ ref('stg_workout_data__sessions') }} s 
        ON se.session_id = s.session_id
),

final AS (
    SELECT
        mab.muscle_activation_estimate_sk,
        mab.fk_entry_id,
        mab.user_id AS fk_user_id,
        mab.exercise_id AS fk_exercise_id,
        mab.fk_muscle_id,
        mab.session_id AS fk_session_id,
        mab.fk_session_date_id AS fk_date_id, 
        mab.activation_score
    FROM muscle_activation_base mab
    WHERE 
        mab.fk_entry_id IS NOT NULL
        AND mab.user_id IS NOT NULL
        AND mab.exercise_id IS NOT NULL
        AND mab.fk_muscle_id IS NOT NULL
        AND mab.session_id IS NOT NULL
        AND mab.fk_session_date_id IS NOT NULL
)

SELECT *
FROM final

{% if is_incremental() %}
    WHERE muscle_activation_estimate_sk NOT IN (
        SELECT muscle_activation_estimate_sk FROM {{ this }}
    )
{% endif %}