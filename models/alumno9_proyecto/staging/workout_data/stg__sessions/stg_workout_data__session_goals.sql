{{ config(materialized="view") }}

with
    src_sessions as (select * from {{ source("workout_data", "sessions_raw") }}),

    prepared_session_goal as (
        select
            {{ dbt_utils.generate_surrogate_key(["session_id"]) }} as session_sk,
            nullif(trim(session_id), '') as session_id,
            case
                when lower(nullif(trim(session_goal), '')) = 'strength'
                then 'strength'
                when lower(nullif(trim(session_goal), '')) = 'hypertrophy'
                then 'hypertrophy'
                when lower(nullif(trim(session_goal), '')) = 'endurance'
                then 'endurance'
                when lower(nullif(trim(session_goal), '')) = 'recovery'
                then 'recovery'
                else null
            end as session_goal
        -- _fivetran_deleted AS _fivetran_deleted,
        -- convert_timezone('UTC',_fivetran_synced) as utc_time
        from src_sessions
    )
select *
from prepared_session_goal
