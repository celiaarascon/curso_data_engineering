{{
    config(
        materialized="view",
        database="ALUMNO9_PROYECTO_SILVER",
        schema="staging_workout_data",
    )
}}

with
    src_sessions as (select * from {{ source("workout_data", "sessions_raw") }}),

    distinct_session_goals as (
        select distinct
            case
                when lower(nullif(trim(session_goal), '')) = 'strength'
                then 'strength'
                when lower(nullif(trim(session_goal), '')) = 'hypertrophy'
                then 'hypertrophy'
                when lower(nullif(trim(session_goal), '')) = 'endurance'
                then 'endurance'
                when lower(nullif(trim(session_goal), '')) = 'recovery'
                then 'recovery'
                else 'unknown'
            end as session_goal
        from src_sessions
        where session_goal is not null
    ),

    prepared_session_goals as (
        select
            {{ dbt_utils.generate_surrogate_key(["session_goal"]) }}
            as fk_session_goal_id,
            initcap(session_goal) as session_goal
        from distinct_session_goals
    )

select *
from prepared_session_goals
