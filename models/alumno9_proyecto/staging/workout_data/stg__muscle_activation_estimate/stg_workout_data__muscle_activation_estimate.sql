{{
    config(
        materialized="view",
        database="ALUMNO9_PROYECTO_SILVER"
    )
}}
with
    src_activation as (
        select * from {{ source("workout_data", "muscle_activation_estimate_raw") }}
    ),

    cleaned_activation as (
        select
            {{ dbt_utils.generate_surrogate_key(["id"]) }} as muscle_activation_sk,
            nullif(trim(id), '') as muscle_activation_id,
            nullif(trim(exercise_id), '') as exercise_id,
            {{ dbt_utils.generate_surrogate_key(["muscle"]) }} as fk_muscle_sk,
            cast(activation_score as decimal(3, 2)) as activation_score

        from src_activation
        where id is not null
    )
select *
from cleaned_activation
