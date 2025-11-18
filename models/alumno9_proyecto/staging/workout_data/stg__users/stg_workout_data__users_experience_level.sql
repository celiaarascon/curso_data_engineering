{{
  config(
    materialized='view'
  )
}}

WITH src_users AS (
    SELECT * 
    FROM {{ source('workout_data', 'users_raw') }}
    ),

renamed_casted AS (
    SELECT
        DISTINCT {{ dbt_utils.generate_surrogate_key(['user_id', 'first_name', 'last_name']) }} AS user_sk,
        trim(user_id) as user_key,
        CASE 
            WHEN experience_level = 'intermediate' THEN 'Intermediate'
            WHEN experience_level = 'advanced' THEN 'Advanced'
            WHEN experience_level = 'beginner' THEN 'Beginner'
            ELSE 'Not specified'
        END AS experience_level_name,
        --_fivetran_deleted AS _fivetran_deleted,
        --convert_timezone('UTC',_fivetran_synced) as utc_time
    FROM src_users
)    
SELECT * FROM renamed_casted