{{
    config(
        materialized='table',
        unique_key='session_id'
    )
}}

WITH session_base AS (
    SELECT
        s.session_id,
        s.user_id,  
        s.duration_minutes,
        s.fk_session_goal_id,
        s.fk_subjective_effort_id,
        s.fk_session_date_id
    FROM {{ ref('stg_workout_data__sessions') }} s
)

SELECT
    sb.session_id,
    sb.user_id,  
    sg.session_goal,
    sb.duration_minutes AS duration_min,
    se.subjective_effort,
    sd.session_date_id AS date_id  
FROM session_base sb
LEFT JOIN {{ ref('stg_workout_data__session_goals') }} sg 
    ON sb.fk_session_goal_id = sg.session_goal_id
LEFT JOIN {{ ref('stg_workout_data__session_subjective_effort') }} se 
    ON sb.fk_subjective_effort_id = se.subjective_effort_id
LEFT JOIN {{ ref('stg_workout_data__session_dates') }} sd 
    ON sb.fk_session_date_id = sd.session_date_id