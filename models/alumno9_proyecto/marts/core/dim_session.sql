{{
    config(
        materialized='table',
        unique_key='session_id',
        database='ALUMNO9_PROYECTO_GOLD'
    )
}}

WITH session_base AS (
    SELECT
        s.session_id,
        s.user_id,  
        s.fk_session_goal_id,
        s.fk_session_date_id,
        cast(sd.session_date as date) as session_date  -- Asegurar que sea fecha
    FROM {{ ref('stg_workout_data__sessions') }} s
    LEFT JOIN {{ ref('stg_workout_data__session_dates') }} sd 
        ON s.fk_session_date_id = sd.session_date_id
)

SELECT
    sb.session_id,
    sb.user_id,  
    sg.session_goal,
    sb.session_date as date_day  -- Usar la fecha real para el join
FROM session_base sb
LEFT JOIN {{ ref('stg_workout_data__session_goals') }} sg 
    ON sb.fk_session_goal_id = sg.session_goal_id