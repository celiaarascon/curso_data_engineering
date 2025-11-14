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
        DISTINCT {{ dbt_utils.generate_surrogate_key(['exercise_id', 'exercise_name', 'movement_type','equipment', 'primary_muscle', 'secondary_muscle']) }} AS exercise_sk,
        nullif(trim(exercise_id),'') as exercise_name_key,
        exercise_name,
        --_fivetran_deleted AS _fivetran_deleted,
        --convert_timezone('UTC',_fivetran_synced) as utc_time
    FROM src_sessions
)    
SELECT * FROM renamed_casted