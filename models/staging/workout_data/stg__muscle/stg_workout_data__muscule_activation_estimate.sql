{{
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
        DISTINCT {{ dbt_utils.generate_surrogate_key(['id', 'exercise_id', 'muscle', 'activation_score']) }} AS muscule_activation_estimate_sk,
        nullif(trim(id),'') as muscule_activation_estimate_key,
        exercise_id,
        muscle,
        activation_score::decimal(10,2),
        --_fivetran_deleted AS _fivetran_deleted,
        --convert_timezone('UTC',_fivetran_synced) as utc_time
    FROM src_sessions
)    
SELECT * FROM renamed_casted