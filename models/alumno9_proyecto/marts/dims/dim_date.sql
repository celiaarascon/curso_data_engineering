{{
    config(
        materialized="table",
        unique_key="date_id",
        database="ALUMNO9_PROYECTO_GOLD"
    )
}}

{% set date_range_query %}
    SELECT 
        MIN(session_date) as min_date,
        MAX(session_date) as max_date
    FROM {{ ref('stg_workout_data__session_dates') }}
{% endset %}

{% set date_range_result = run_query(date_range_query) %}

{% if execute %}
    {% set min_date = date_range_result.columns[0].values()[0] %}
    {% set max_date = date_range_result.columns[1].values()[0] %}
{% else %} {% set min_date = "2020-01-01" %} {% set max_date = "2030-12-31" %}
{% endif %}

with
    date_spine as (
        {{
            dbt_utils.date_spine(
                datepart="day",
                start_date="'" ~ min_date ~ "'",
                end_date="'" ~ max_date ~ "'",
            )
        }}
    ),

    existing_dates as (
        select session_date_id, session_date
        from {{ ref("stg_workout_data__session_dates") }}
    ),

    date_attributes as (
        select
            session_date,
            extract(day from date_day) as day,
            extract(month from date_day) as month,
            extract(week from date_day) as week,
            coalesce(
                ed.session_date_id, {{ dbt_utils.generate_surrogate_key(["date_day"]) }}
            ) as date_id
        from date_spine ds
        left join existing_dates ed on ds.date_day = ed.session_date
    )

select date_id, session_date, day, month, week
from date_attributes
