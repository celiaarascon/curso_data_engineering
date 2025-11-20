{{
    config(
        materialized="view",
        database="ALUMNO9_PROYECTO_SILVER"
    )
}}

with
    src_sessions as (select * from {{ source("workout_data", "sessions_raw") }}),

    cleaned_sessions as (
        select
            {{ dbt_utils.generate_surrogate_key(["session_id"]) }} as session_sk,
            nullif(trim(session_id), '') as session_id,
            nullif(trim(user_id), '') as user_id,
            try_cast(duration_min as integer) as duration_minutes,
            {{ dbt_utils.generate_surrogate_key(["session_goal"]) }}
            as fk_session_goal_id,
            {{ dbt_utils.generate_surrogate_key(["subjective_effort"]) }}
            as fk_subjective_effort_id,
            {{ dbt_utils.generate_surrogate_key(["session_date"]) }}
            as fk_session_date_id
        from src_sessions
    )

select *
from cleaned_sessions
