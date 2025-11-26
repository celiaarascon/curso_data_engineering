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
        s.fk_session_date_id
    FROM {{ ref('stg_workout_data__sessions') }} s
)

SELECT
    sb.session_id,
    sb.user_id,  
    sg.session_goal,
    sd.session_date_id AS date_id  
FROM session_base sb
LEFT JOIN {{ ref('stg_workout_data__session_goals') }} sg 
    ON sb.fk_session_goal_id = sg.session_goal_id
LEFT JOIN {{ ref('stg_workout_data__session_dates') }} sd 
    ON sb.fk_session_date_id = sd.session_date_id