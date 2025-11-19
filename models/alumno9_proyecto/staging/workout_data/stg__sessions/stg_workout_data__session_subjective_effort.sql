{{ config(materialized="view") }}

with
    src_sessions as (select * from {{ source("workout_data", "sessions_raw") }}),

    prepared_subjective_effort as (
        select
            {{ dbt_utils.generate_surrogate_key(["session_id"]) }} as session_sk,
            nullif(trim(session_id), '') as session_id,
            cast(subjective_effort as integer) as subjective_effort
        -- _fivetran_deleted AS _fivetran_deleted,
        -- convert_timezone('UTC',_fivetran_synced) as utc_time
        from src_sessions
        where subjective_effort is not null
    )
select *
from prepared_subjective_effort
