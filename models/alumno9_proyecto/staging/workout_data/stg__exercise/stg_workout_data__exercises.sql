{{ config(materialized="view") }}

with
    src_exercises as (select * from {{ source("workout_data", "exercises_raw") }}),

    cleaned_exercises as (
        select
            {{ dbt_utils.generate_surrogate_key(["exercise_id"]) }} as exercise_sk,
            nullif(trim(exercise_id), '') as exercise_id,
            nullif(trim(exercise_name), '') as exercise_name
        -- _fivetran_deleted AS _fivetran_deleted,
        -- convert_timezone('UTC',_fivetran_synced) as utc_time
        from src_exercises
    )
select *
from cleaned_exercises
