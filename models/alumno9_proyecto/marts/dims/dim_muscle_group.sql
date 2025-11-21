{{
    config(
        materialized='table',
        unique_key='muscle_id'
    )
}}

SELECT
    muscle_id,
    muscle_name
FROM {{ ref('stg_workout_data__muscle') }}