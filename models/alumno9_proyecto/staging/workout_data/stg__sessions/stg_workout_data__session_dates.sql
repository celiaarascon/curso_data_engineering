{{ config(materialized="view") }}

with
    src_sessions as (select * from {{ source("workout_data", "sessions_raw") }}),

    prepared_date as (
        select
            {{ dbt_utils.generate_surrogate_key(["session_id"]) }} as session_sk,
            nullif(trim(session_id), '') as session_id,
            cast(session_date as date) as session_date,
        -- EXTRACT(YEAR FROM CAST(session_date AS DATE)) AS session_year,
        -- EXTRACT(MONTH FROM CAST(session_date AS DATE)) AS session_month,
        -- EXTRACT(DAY FROM CAST(session_date AS DATE)) AS session_day
        -- _fivetran_deleted AS _fivetran_deleted,
        -- convert_timezone('UTC',_fivetran_synced) as utc_time
        from src_sessions
    )
select *
from prepared_date
