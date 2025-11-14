{{
  config(
    materialized='view'
  )
}}

WITH src_sessions AS (
    SELECT * 
    FROM {{ source('workout_data', 'exercises_raw') }}
    ),

renamed_casted AS (
    SELECT
        md5(movement_type) as movement_type_id,
        movement_type as movement_type_name
        --_fivetran_deleted AS _fivetran_deleted,
        --convert_timezone('UTC',_fivetran_synced) as utc_time
    FROM src_sessions
)    
SELECT * FROM renamed_casted