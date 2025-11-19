{{ config(materialized="view") }}

with
    src_sessions as (select * from {{ source("workout_data", "sessions_raw") }}),

    cleaned_sessions as (
        select
            {{ dbt_utils.generate_surrogate_key(["session_id"]) }} as session_sk,
            nullif(trim(session_id), '') as session_id,
            nullif(trim(user_id), '') as user_id
        -- _fivetran_deleted AS _fivetran_deleted,
        -- convert_timezone('UTC',_fivetran_synced) as utc_time
        from src_sessions
    )
select *
from cleaned_sessions
