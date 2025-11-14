/*{{
  config(
    materialized='view'
  )
}}

WITH src_sessions AS (
    SELECT * 
    FROM {{ source('workout_data', 'muscule_activation_estimate_raw') }}
    ),

renamed_casted AS (
    SELECT
        trim(id) as muscule_activation_estimate_key,
        muscle as muscle_name
        --_fivetran_deleted AS _fivetran_deleted,
        --convert_timezone('UTC',_fivetran_synced) as utc_time
    FROM src_sessions
)    
SELECT * FROM renamed_casted