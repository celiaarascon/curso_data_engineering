{{ config(materialized="view") }}

with
    src_exercises as (select * from {{ source("workout_data", "exercises_raw") }}),

    muscle_groups_prep as (
        select
            {{ dbt_utils.generate_surrogate_key(["exercise_id"]) }} as exercise_sk,
            nullif(trim(exercise_id), '') as exercise_id,
            initcap(nullif(trim(primary_muscle), '')) as primary_muscle,
            initcap(nullif(trim(secondary_muscle), '')) as secondary_muscle
        -- _fivetran_deleted AS _fivetran_deleted,
        -- convert_timezone('UTC',_fivetran_synced) as utc_time
        from src_exercises
    )
select *
from muscle_groups_prep
