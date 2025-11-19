{{ config(materialized="view") }}

with
    src_exercises as (select * from {{ source("workout_data", "exercises_raw") }}),

    prepared_equipment as (
        select
            {{ dbt_utils.generate_surrogate_key(["exercise_id"]) }} as exercise_sk,
            nullif(trim(exercise_id), '') as exercise_id,
            case
                when upper(nullif(trim(equipment), '')) = 'BARBELL'
                then 'Barbell'
                when upper(nullif(trim(equipment), '')) = 'DUMBBELL'
                then 'Dumbbell'
                when upper(nullif(trim(equipment), '')) = 'MACHINE'
                then 'Machine'
                when upper(nullif(trim(equipment), '')) = 'CABLE'
                then 'Cable'
                else nullif(trim(equipment), '')
            end as equipment
        -- _fivetran_deleted AS _fivetran_deleted,
        -- convert_timezone('UTC',_fivetran_synced) as utc_time
        from src_exercises
    )
select *
from prepared_equipment
