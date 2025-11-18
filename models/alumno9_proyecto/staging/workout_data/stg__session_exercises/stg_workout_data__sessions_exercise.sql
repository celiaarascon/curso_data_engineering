{{
  config(
    materialized='view'
  )
}}

WITH src_sessions AS (
    SELECT * 
    FROM {{ source('workout_data', 'session_exercises_raw') }}
    ),

renamed_casted AS (
    SELECT
        trim(entry_id) as entry_name_key,
        session_id,
        exercise_id
        --_fivetran_deleted AS _fivetran_deleted,
        --convert_timezone('UTC',_fivetran_synced) as utc_time
    FROM src_sessions
)    
SELECT * FROM renamed_casted