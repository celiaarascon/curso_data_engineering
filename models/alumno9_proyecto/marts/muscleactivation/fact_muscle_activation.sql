{{ config(
    materialized = 'table'
) }}


WITH muscle_activation_base AS (
    SELECT
        ma.exercise_id AS fk_exercise_id,
        ma.fk_muscle_id AS fk_muscle_id_raw,
        ma.activation_score,
        fep.fk_user_id AS fk_user_id,
        fep.entry_id AS fk_entry_id,
        ds.session_id
    FROM {{ ref('stg_workout_data__muscle_activation_estimate') }} ma
    LEFT JOIN {{ ref('dim_exercise') }} de
        ON ma.exercise_id = de.exercise_id
    LEFT JOIN {{ ref('fact_exercise_performance') }} fep
        ON de.exercise_id = fep.fk_exercise_id
    LEFT JOIN {{ ref('dim_session') }} ds
        ON fep.fk_session_id = ds.session_id
    WHERE 
        fep.fk_user_id IS NOT NULL
        AND ma.exercise_id IS NOT NULL
        AND ma.fk_muscle_id IS NOT NULL
        AND ds.session_id IS NOT NULL
),

muscle_mapped AS (
    SELECT
        mab.fk_exercise_id,
        dmg.muscle_id AS fk_muscle_id,
        dmg.muscle_name,
        mab.activation_score,
        mab.fk_user_id,
        mab.fk_entry_id
    FROM muscle_activation_base mab
    LEFT JOIN {{ ref('dim_muscle_group') }} dmg
        ON mab.fk_muscle_id_raw = dmg.muscle_id
),

activation_stats AS (
    SELECT
        fk_muscle_id,
        fk_exercise_id,
        ROUND(AVG(activation_score), 3) AS avg_activation,
        COUNT(*) AS total_measures,
        COUNT(DISTINCT fk_user_id) AS unique_users
    FROM muscle_mapped
    GROUP BY fk_muscle_id, fk_exercise_id
    HAVING COUNT(*) >= 3
),

ranked_exercises AS (
    SELECT
        fk_muscle_id,
        fk_exercise_id,
        avg_activation,
        total_measures,
        unique_users,
        ROW_NUMBER() OVER (
            PARTITION BY fk_muscle_id
            ORDER BY avg_activation DESC, total_measures DESC
        ) AS muscle_ranked
    FROM activation_stats
)

SELECT
    re.fk_muscle_id,
    mm.fk_entry_id,
    re.fk_exercise_id,
    dmg.muscle_name,
    de.exercise_name,
    re.avg_activation,
    re.total_measures,
    re.unique_users,
    re.muscle_ranked,
    CASE 
        WHEN re.avg_activation >= 0.8 THEN 'Very High Activation'
        WHEN re.avg_activation >= 0.6 THEN 'High Activation'
        WHEN re.avg_activation >= 0.4 THEN 'Medium Activation'
        WHEN re.avg_activation >= 0.2 THEN 'Low Activation'
        ELSE 'Very Low Activation'
    END AS activation_level
FROM ranked_exercises re
LEFT JOIN {{ ref('dim_muscle_group') }} dmg
    ON re.fk_muscle_id = dmg.muscle_id
LEFT JOIN {{ ref('dim_exercise') }} de
    ON re.fk_exercise_id = de.exercise_id
LEFT JOIN muscle_mapped mm
    ON mm.fk_exercise_id = re.fk_exercise_id
WHERE muscle_ranked <= 10
ORDER BY re.fk_muscle_id, re.muscle_ranked
