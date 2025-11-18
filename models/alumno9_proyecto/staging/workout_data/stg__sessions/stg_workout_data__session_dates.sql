{{
  config(
    materialized='view'
  )
}}

WITH src_sessions AS (
    SELECT * 
    FROM {{ source('workout_data', 'sessions_raw') }}
    ),

renamed_casted AS (
    SELECT
        trim(session_id) as session_name_key,
        md5(trim(session_id)) as session_date_id,
        date
        --_fivetran_deleted AS _fivetran_deleted,
        --convert_timezone('UTC',_fivetran_synced) as utc_time
    FROM src_sessions
)    
SELECT * FROM renamed_casted