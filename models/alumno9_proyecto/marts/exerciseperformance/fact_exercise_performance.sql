{{ config(materialized="table") }}

WITH
-- 1. Datos base de ejercicios de sesión
exercise_data AS (
    SELECT
        se.entry_id,
        se.session_id,
        se.exercise_id,
        se.weight_kg,
        se.volume_kg AS volumen_kg,
        se.estimated_1_rep_max AS estimated_1rm,
        ds.user_id AS fk_user_id,
        ds.session_goal,
        ds.date_id AS fk_date_id,
        dd.session_date
    FROM {{ ref("stg_workout_data__session_exercises") }} se
    INNER JOIN {{ ref("dim_session") }} ds 
        ON se.session_id = ds.session_id
    LEFT JOIN {{ ref("dim_date") }} dd 
        ON ds.date_id = dd.date_id
),

-- 2. Join explícito a dim_user para lineage
exercise_with_user AS (
    SELECT
        *
    FROM exercise_data ed
    LEFT JOIN {{ ref("dim_users") }} du
        ON ed.fk_user_id = du.user_id
),

-- 3. Volumen semanal por usuario
weekly_volume AS (
    SELECT
        fk_user_id,
        session_id,
        fk_date_id,
        session_date,
        DATE_TRUNC('week', session_date) AS week_start_date,
        SUM(volumen_kg) AS volume_kg_total_weekly
    FROM exercise_with_user
    GROUP BY fk_user_id, session_id, fk_date_id, session_date
),

-- 4. Datos finales del hecho
final AS (
    SELECT
        e.entry_id,
        e.fk_user_id,
        e.exercise_id AS fk_exercise_id,
        e.session_id AS fk_session_id,
        e.fk_date_id,
        e.weight_kg,
        e.volumen_kg,
        e.estimated_1rm,
        (e.estimated_1rm - e.weight_kg) AS diff_weight_vs_1rm,
        e.session_goal,
        CASE 
            WHEN e.estimated_1rm > 0 AND e.weight_kg / e.estimated_1rm >= 0.80 THEN 'Strength'
            WHEN e.estimated_1rm > 0 AND e.weight_kg / e.estimated_1rm >= 0.60 THEN 'Hypertrophy'
            WHEN e.estimated_1rm > 0 THEN 'Endurance'
            ELSE 'Unknown'
        END AS intensity_category,
        e.session_date,
        wv.volume_kg_total_weekly,
        SUM(wv.volume_kg_total_weekly) OVER (
            PARTITION BY e.fk_user_id, DATE_TRUNC('week', e.session_date)
        ) AS total_weekly_volume_per_user,
        RANK() OVER (
            PARTITION BY DATE_TRUNC('week', e.session_date)
            ORDER BY wv.volume_kg_total_weekly DESC
        ) AS weekly_volume_rank
    FROM exercise_with_user e
    LEFT JOIN weekly_volume wv
        ON e.session_id = wv.session_id
        AND e.fk_user_id = wv.fk_user_id
        AND e.session_date = wv.session_date
)

SELECT *
FROM final
