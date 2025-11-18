{{
  config(
    materialized='view'
  )
}}

WITH src_sessions AS (
    SELECT * 
    FROM {{ source('workout_data', 'muscle_activation_estimate_raw') }}
    ),

renamed_casted AS (
    SELECT
        DISTINCT {{ dbt_utils.generate_surrogate_key(['id', 'exercise_id', 'muscle', 'activation_score']) }} AS muscule_activation_estimate_sk,
        nullif(trim(id),'')::varchar as muscule_activation_estimate_key,
        cast(exercise_id as varchar) as exercise_id,
        cast(muscle as varchar) as muscle,
        cast(activation_score as number(10,2)) as activation_score
        --_fivetran_deleted AS _fivetran_deleted,
        --convert_timezone('UTC',_fivetran_synced) as utc_time
    FROM src_sessions
)    
SELECT * FROM renamed_casted