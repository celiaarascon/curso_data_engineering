{{ config(materialized="view") }}

with
    src_session_exercises as (
        select * from {{ source("workout_data", "session_exercises_raw") }}
    ),

    prepared_session_exercise as (
        select
            {{ dbt_utils.generate_surrogate_key(["entry_id"]) }} as session_exercise_sk,
            nullif(trim(entry_id), '') as entry_id,
            cast(sets as integer) as sets_count,
            cast(reps as integer) as reps_count,
            cast(weight_kg as decimal(8, 2)) as weight_kg,
            cast(sets as integer)
            * cast(reps as integer)
            * cast(weight_kg as decimal(8, 2)) as total_volume_kg,
            cast(estimated_1rm as decimal(8, 2)) as estimated_one_rep_max,
        -- _fivetran_deleted AS _fivetran_deleted,
        -- convert_timezone('UTC',_fivetran_synced) as utc_time
        from src_session_exercises
        where sets is not null and reps is not null and weight_kg is not null
    )
select *
from prepared_session_exercise
