{{
    config(
        materialized="view",
        database="ALUMNO9_PROYECTO_SILVER"
    )
}}

with
    src_sessions as (select * from {{ source("workout_data", "sessions_raw") }}),

    prepared_date as (
        select distinct
            {{ dbt_utils.generate_surrogate_key(["session_date"]) }}
            as session_date_id,
            cast(session_date as date) as session_date
        from src_sessions
        order by session_date asc
    )

select *
from prepared_date
