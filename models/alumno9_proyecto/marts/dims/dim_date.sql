{{
    config(
        materialized='table',
        unique_key='date_id'
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
{% else %}
    {% set min_date = '2020-01-01' %}
    {% set max_date = '2030-12-31' %}
{% endif %}

WITH date_spine AS (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="'" ~ min_date ~ "'",
        end_date="'" ~ max_date ~ "'"
    ) }}
),

-- Obtener los session_date_id existentes de tu staging
existing_dates AS (
    SELECT 
        session_date_id,
        session_date
    FROM {{ ref('stg_workout_data__session_dates') }}
),

date_attributes AS (
    SELECT
        EXTRACT(DAY FROM date_day) AS day,
        EXTRACT(MONTH FROM date_day) AS month,
        EXTRACT(YEAR FROM date_day) AS year,
        EXTRACT(WEEK FROM date_day) AS week,
        COALESCE(ed.session_date_id, {{ dbt_utils.generate_surrogate_key(["date_day"]) }}) AS date_id
    FROM date_spine ds
    LEFT JOIN existing_dates ed ON ds.date_day = ed.session_date
)

SELECT
    date_id,
    day,
    month,
    year,
    week
FROM date_attributes
