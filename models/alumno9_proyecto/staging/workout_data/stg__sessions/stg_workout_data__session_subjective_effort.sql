{{
    config(
        materialized="view",
        database="ALUMNO9_PROYECTO_SILVER",
        schema="staging_workout_data",
    )
}}

with
    src_sessions as (select * from {{ source("workout_data", "sessions_raw") }}),

    distinct_subjective_effort as (
        select distinct cast(subjective_effort as integer) as subjective_effort
        from src_sessions
        where subjective_effort is not null
    ),

    prepared_subjective_effort as (
        select
            {{ dbt_utils.generate_surrogate_key(["subjective_effort"]) }}
            as subjective_effort_id,
            subjective_effort,
            case
                when subjective_effort <= 6
                then 'Low'
                when subjective_effort <= 8
                then 'Medium'
                else 'High'
            end as subjective_effort_description
        from distinct_subjective_effort
    )

select *
from prepared_subjective_effort
