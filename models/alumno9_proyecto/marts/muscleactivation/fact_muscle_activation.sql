{{
    config(
        materialized='table'
    )
}}

WITH muscle_activation_base AS (
    SELECT
        ma.exercise_id,
        ma.fk_muscle_id,
        ma.activation_score,
        fep.entry_id AS fk_entry_id,  
        fep.fk_user_id AS user_id, 
        ds.date_id AS fk_session_date_id
    FROM {{ ref('stg_workout_data__muscle_activation_estimate') }} ma
    LEFT JOIN {{ ref('dim_exercise') }} de
        ON ma.exercise_id = de.exercise_id
    LEFT JOIN {{ ref('fact_exercise_performance') }} fep
        ON de.exercise_id = fep.fk_exercise_id  
    LEFT JOIN {{ ref('dim_session') }} ds
        ON fep.fk_session_id = ds.session_id  

    WHERE 
        fep.entry_id IS NOT NULL
        AND fep.fk_user_id IS NOT NULL  
        AND ma.exercise_id IS NOT NULL
        AND ma.fk_muscle_id IS NOT NULL
        AND ds.session_id IS NOT NULL
        AND ds.date_id IS NOT NULL
),

activation_stats AS (
    SELECT
        fk_muscle_id,
        exercise_id AS fk_exercise_id,
        ROUND(AVG(activation_score), 3) as avg_activation,
        COUNT(*) as total_measures,
        COUNT(DISTINCT user_id) as unique_users,
        ROUND(
            COUNT(CASE WHEN activation_score >= 0.7 THEN 1 END) * 100.0 /
            NULLIF(COUNT(*), 0), 
        1) as percentage_activation
    FROM muscle_activation_base
    GROUP BY fk_muscle_id, exercise_id
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
        ) as muscle_ranked
    FROM activation_stats
)

SELECT 
    re.fk_muscle_id,
    re.fk_exercise_id,
    dm.muscle_name AS muscle_name,  
    de.exercise_name AS exercise_name,  
    re.avg_activation AS avg_activation,
    re.total_measures AS total_measures,
    re.unique_users AS unique_users,
    re.muscle_ranked AS muscle_ranked,
    CASE 
        WHEN re.avg_activation >= 0.8 THEN 'Very High Activation'
        WHEN re.avg_activation >= 0.6 THEN 'High Activation'
        WHEN re.avg_activation >= 0.4 THEN 'Medium Activation'
        WHEN re.avg_activation >= 0.2 THEN 'Low Activation'
        ELSE 'Very Low Activation'
    END AS activation_level
FROM ranked_exercises re
LEFT JOIN {{ ref('dim_muscle_group') }} dm ON re.fk_muscle_id = dm.muscle_id
LEFT JOIN {{ ref('dim_exercise') }} de ON re.fk_exercise_id = de.exercise_id
WHERE muscle_ranked <= 10
ORDER BY re.fk_muscle_id, re.muscle_ranked