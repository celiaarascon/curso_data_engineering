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
        md5(trim(entry_id)) as entry_id,
        TRY_CAST(sets AS INTEGER) as sets,
        TRY_CAST(reps AS INTEGER) as reps,
        TRY_CAST(weight_kg AS FLOAT) as weight_kg,
        (TRY_CAST(sets AS INTEGER) * TRY_CAST(reps AS INTEGER) * TRY_CAST(weight_kg AS FLOAT)) AS volume_kg,       
        TRY_CAST(estimated_1rm AS FLOAT) as estimated_1rm
        --_fivetran_deleted AS _fivetran_deleted,
        --convert_timezone('UTC',_fivetran_synced) as utc_time
    FROM src_sessions
    WHERE 
        sets IS NOT NULL 
        AND reps IS NOT NULL 
        AND weight_kg IS NOT NULL
)
SELECT * FROM renamed_casted