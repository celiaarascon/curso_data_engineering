{{
    config(
        materialized='table',
        unique_key='user_id',
        database='ALUMNO9_PROYECTO_GOLD'
    )
}}

WITH user_base AS (
    SELECT
        u.user_id,
        u.first_name,
        u.last_name,
        u.fk_sex_id
    FROM {{ ref('stg_workout_data__users') }} u
)

SELECT
    ub.user_id,
    ub.first_name,
    ub.last_name,
    s.sex,
FROM user_base ub
LEFT JOIN {{ ref('stg_workout_data__users_sex') }} s 
    ON ub.fk_sex_id = s.sex_id
