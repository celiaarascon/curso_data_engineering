{{
    config(
        materialized="view",
        database="ALUMNO9_PROYECTO_SILVER",
        schema="staging_workout_data",
    )
}}

with
    src_sessions as (select * from {{ source("workout_data", "sessions_raw") }}),

    prepared_date as (
        select
            {{ dbt_utils.generate_surrogate_key(["session_date"]) }}
            as fk_session_date_id,
            cast(session_date as date) as session_date,
            extract(year from cast(session_date as date)) as session_year,
            extract(month from cast(session_date as date)) as session_month,
            extract(day from cast(session_date as date)) as session_day
        from src_sessions
    )

select *
from prepared_date
