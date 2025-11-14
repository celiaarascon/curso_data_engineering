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
        nullif(trim(user_id),'') as user_key,
        CASE 
            WHEN upper(sex) = 'F' THEN 'Female'
            WHEN upper(sex) = 'M' THEN 'Male'
            ELSE 'Not specified'
        END AS sex_name        
        --_fivetran_deleted AS _fivetran_deleted,
        --convert_timezone('UTC',_fivetran_synced) as utc_time
    FROM src_users
)    
SELECT * FROM renamed_casted