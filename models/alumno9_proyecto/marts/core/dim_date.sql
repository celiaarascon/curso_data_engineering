{{
    config(
        materialized="table",
    )
}}

{% set start_date = '2020-01-01' %}
{% set end_date = '2030-12-31' %}

with full_dates as (
    {{ dbt_date.get_date_dimension(start_date, end_date) }}
)

select
    date_day,
    day_of_week,
    day_of_week_name,
    day_of_month,
    week_of_year,
    month_name,
    month_of_year,
from full_dates
