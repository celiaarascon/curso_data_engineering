{{
    config(
        materialized='table',
        unique_key='user_id'
    )
}}

WITH user_base AS (
    SELECT
        u.user_id,
        u.first_name,
        u.last_name,
        u.fk_age_id,
        u.fk_sex_id,
        u.fk_experience_level_id
    FROM {{ ref('stg_workout_data__users') }} u
)

SELECT
    ub.user_id,
    ub.first_name,
    ub.last_name,
    a.age_group AS age,
    s.sex,
    el.experience_level_description AS experience_level
FROM user_base ub
LEFT JOIN {{ ref('stg_workout_data__users_age') }} a 
    ON ub.fk_age_id = a.age_id
LEFT JOIN {{ ref('stg_workout_data__users_sex') }} s 
    ON ub.fk_sex_id = s.sex_id
LEFT JOIN {{ ref('stg_workout_data__users_experience_level') }} el 
    ON ub.fk_experience_level_id = el.experience_level_id