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
        CASE 
            WHEN upper(equipment_name) = 'Barbell' THEN 'Barbell'
            WHEN upper(equipment_name) = 'Machine' THEN 'Machine'
            WHEN upper(equipment_name) = 'Cable' THEN 'Cable'
            WHEN upper(equipment_name) = 'Dumbbell' THEN 'Dumbbell'
            ELSE 'Not specified'
        END AS equipment_name
        --_fivetran_deleted AS _fivetran_deleted,
        --convert_timezone('UTC',_fivetran_synced) as utc_time
    FROM src_sessions
)    
SELECT * FROM renamed_casted