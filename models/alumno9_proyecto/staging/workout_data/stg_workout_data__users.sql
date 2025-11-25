{{
    config(
        materialized="incremental",
        unique_key="user_id",
        database="ALUMNO9_PROYECTO_SILVER",
        on_schema_change="sync_all_columns",
    )
}}

with
    src_users as (select * from {{ source("workout_data", "users_raw") }}),

    cleaned_users as (
        select
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
            as fk_experience_level_id,
            _fivetran_synced

        from src_users
    )

select *
from cleaned_users

{% if is_incremental() %}

    where
        _fivetran_synced > (
            select coalesce(max(_fivetran_synced), cast('1900-01-01' as timestamp))
            from {{ this }}
        )

{% endif %}