{{ config(materialized="view", database="ALUMNO9_PROYECTO_SILVER", schema="staging_workout_data") }}

with
    src_users as (select * from {{ source("workout_data", "users_raw") }}),

    cleaned_users as (
        select
            {{ dbt_utils.generate_surrogate_key(["user_id"]) }} as user_sk,
            nullif(trim(user_id), '') as user_id,
            initcap(nullif(trim(first_name), '')) as first_name,
            initcap(nullif(trim(last_name), '')) as last_name,
            {{
                dbt_utils.generate_surrogate_key(
                    [
                        "case
                             when cast(age as integer) < 25 then '18-24'
                             when cast(age as integer) < 35 then '25-34'
                             when cast(age as integer) < 45 then '35-44'
                             else '45+'
                         end"
                    ]
                )
            }} as fk_age_id,
            {{ dbt_utils.generate_surrogate_key(["sex"]) }} as fk_sex_id,
            {{ dbt_utils.generate_surrogate_key(["experience_level"]) }}
            as fk_experience_level_id
        from src_users
    )

select *
from cleaned_users
