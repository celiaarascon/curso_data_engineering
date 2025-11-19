{{ config(materialized="view") }}

with
    src_sessions as (select * from {{ source("workout_data", "sessions_raw") }}),

    prepared_duration as (
        select
            {{ dbt_utils.generate_surrogate_key(["session_id"]) }} as session_sk,
            nullif(trim(session_id), '') as session_id,
            cast(duration_min as integer) as duration_minutes
        -- _fivetran_deleted AS _fivetran_deleted,
        -- convert_timezone('UTC',_fivetran_synced) as utc_time
        from src_sessions
    )
select *
from prepared_duration
