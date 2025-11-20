{{
    config(
        materialized="view",
        database="ALUMNO9_PROYECTO_SILVER"
    )
}}

with
    src_muscle as (
        select * from {{ source("workout_data", "muscle_activation_estimate_raw") }}
    ),

    distinct_muscles as (
        select distinct
            initcap(nullif(trim(muscle), '')) as muscle_name
        from src_muscle
        where muscle is not null and trim(muscle) != ''
    ),

    cleaned_muscle as (
        select
            {{ dbt_utils.generate_surrogate_key(["muscle_name"]) }} as muscle_sk,
            muscle_name
        from distinct_muscles
    )

select *
from cleaned_muscle