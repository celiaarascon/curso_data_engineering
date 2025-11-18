{{ config(
    materialized='view'
) }}

WITH src_users AS (
    SELECT * 
    FROM {{ source('workout_data', 'users_raw') }}
),

renamed_casted AS (
    SELECT
        DISTINCT {{ dbt_utils.generate_surrogate_key(['user_id', 'first_name', 'last_name']) }} AS user_sk,
        nullif(trim(user_id),'') AS user_name_key,
        first_name:: varchar as first_name,
        last_name:: varchar as last_name,
        age:: number as age
    FROM src_users
)

SELECT * FROM renamed_casted