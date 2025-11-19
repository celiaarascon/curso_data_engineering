{{
    config(
        materialized="view",
        database="ALUMNO9_PROYECTO_SILVER",
        schema="staging_workout_data",
    )
}}

with
    src_exercises as (select * from {{ source("workout_data", "exercises_raw") }}),

    distinct_equipment as (
        select distinct
            case
                when upper(nullif(trim(equipment), '')) = 'BARBELL'
                then 'Barbell'
                when upper(nullif(trim(equipment), '')) = 'DUMBBELL'
                then 'Dumbbell'
                when upper(nullif(trim(equipment), '')) = 'MACHINE'
                then 'Machine'
                when upper(nullif(trim(equipment), '')) = 'CABLE'
                then 'Cable'
                else nullif(trim(equipment), '')
            end as equipment
        from src_exercises
        where equipment is not null
    ),

    prepared_equipment as (
        select
            {{ dbt_utils.generate_surrogate_key(["equipment"]) }} as equipment_id,
            equipment_name,
        from distinct_equipment
    )

select *
from prepared_equipment
