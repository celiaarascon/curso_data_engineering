{{ config(materialized="view") }}

with
    src_session_exercises as (
        select * from {{ source("workout_data", "session_exercises_raw") }}
    ),

    cleaned_session_exercises as (
        select
            {{ dbt_utils.generate_surrogate_key(["entry_id"]) }} as session_exercise_sk,
            nullif(trim(entry_id), '') as entry_id,
            nullif(trim(session_id), '') as session_id,
            nullif(trim(exercise_id), '') as exercise_id,
        -- _fivetran_deleted AS _fivetran_deleted,
        -- convert_timezone('UTC',_fivetran_synced) as utc_time
        from src_session_exercises
    )
select *
from cleaned_session_exercises
