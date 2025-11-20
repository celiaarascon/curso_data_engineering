{% snapshot snapshot_user_experience_changes %}

{{
    config(
        target_database='ALUMNO9_PROYECTO_SILVER',
        target_schema='snapshots',
        unique_key='user_sk',
        strategy='timestamp',
        updated_at='snapshot_timestamp',
        invalidate_hard_deletes=True
    )
}}

with 
    stg_users as (
        select 
            user_sk,
            user_id,
            first_name,
            last_name,
            fk_experience_level_id,
            _fivetran_synced,
            CURRENT_TIMESTAMP() as snapshot_timestamp
        from {{ ref('stg_workout_data__users') }}
    ),
    
    experience_levels as (
        select 
            experience_level_id,
            experience_level
        from {{ ref('stg_workout_data__users_experience_level') }}
    ),

    final_users as (
        select 
            u.user_sk,
            u.user_id,
            u.first_name,
            u.last_name,
            u.fk_experience_level_id,
            el.experience_level as experience_level_description,
            u._fivetran_synced,
            u.snapshot_timestamp
        from stg_users u
        left join experience_levels el 
            on u.fk_experience_level_id = el.experience_level_id
    )

select * from final_users
{% endsnapshot %}