{{ config(materialized="view") }}

with
    src_exercises as (select * from {{ source("workout_data", "exercises_raw") }}),

    prepared_movement_type as (
        select
            {{ dbt_utils.generate_surrogate_key(["exercise_id"]) }} as exercise_sk,
            nullif(trim(exercise_id), '') as exercise_id,
            case
                when lower(nullif(trim(movement_type), '')) = 'compound'
                then 'compound'
                when lower(nullif(trim(movement_type), '')) = 'isolation'
                then 'isolation'
                else null
            end as movement_type
        -- _fivetran_deleted AS _fivetran_deleted,
        -- convert_timezone('UTC',_fivetran_synced) as utc_time
        from src_exercises
    )
select *
from prepared_movement_type
