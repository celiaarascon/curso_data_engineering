{{ config(materialized="table") }}

with
    exercise_data as (
        select
            se.entry_id,
            se.session_id,
            se.exercise_id,
            se.weight_kg,
            se.volume_kg as volumen_kg,
            se.estimated_1_rep_max as estimated_1rm,
            ds.user_id as fk_user_id,
            ds.session_goal,
            dd.date_day as fk_date_day,  -- Cambiado: usar date_day de dim_session
            dd.date_day as session_date
        from {{ ref("stg_workout_data__session_exercises") }} se
        inner join {{ ref("dim_session") }} ds on se.session_id = ds.session_id
        left join {{ ref("dim_date") }} dd on ds.date_day = dd.date_day  -- Cambiado: join por date_day
    ),

    exercise_with_user as (
        select *
        from exercise_data ed
        left join {{ ref("dim_users") }} du on ed.fk_user_id = du.user_id
    ),

    weekly_volume as (
        select
            fk_user_id,
            session_id,
            fk_date_day,
            session_date,
            sum(volumen_kg) as volume_kg_total
        from exercise_with_user
        group by fk_user_id, session_id, fk_date_day, session_date
    ),

    final as (
        select
            e.entry_id,
            e.fk_user_id,
            e.exercise_id as fk_exercise_id,
            e.session_id as fk_session_id,
            e.fk_date_day,
            e.weight_kg,
            e.volumen_kg,
            e.estimated_1rm,
            (e.estimated_1rm - e.weight_kg) as diff_weight_vs_1rm,
            e.session_goal,
            case
                when e.estimated_1rm > 0 and e.weight_kg / e.estimated_1rm >= 0.80
                then 'Strength'
                when e.estimated_1rm > 0 and e.weight_kg / e.estimated_1rm >= 0.60
                then 'Hypertrophy'
                when e.estimated_1rm > 0
                then 'Endurance'
                else 'Unknown'
            end as intensity_category,
            e.session_date,
            wv.volume_kg_total,
            sum(wv.volume_kg_total) over (
                partition by e.fk_user_id, date_trunc('week', e.session_date)
            ) as total_volume_per_user,
            rank() over (
                partition by date_trunc('week', e.session_date)
                order by wv.volume_kg_total
            ) as volume_rank
        from exercise_with_user e
        left join
            weekly_volume wv
            on e.session_id = wv.session_id
            and e.fk_user_id = wv.fk_user_id
            and e.session_date = wv.session_date
    )

select *
from final
