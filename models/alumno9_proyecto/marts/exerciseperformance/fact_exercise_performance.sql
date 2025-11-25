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
            ds.date_id as fk_date_id,
            dd.session_date
        from {{ ref("stg_workout_data__session_exercises") }} se
        inner join {{ ref("dim_session") }} ds on se.session_id = ds.session_id
        left join {{ ref("dim_date") }} dd on ds.date_id = dd.date_id
    ),

    weekly_volume as (
        select
            fk_user_id,
            session_id,
            fk_date_id,
            session_date,
            date_trunc('week', session_date) as week_start_date,
            sum(volumen_kg) as volume_kg_total_weekly
        from exercise_data
        group by fk_user_id, session_id, fk_date_id, session_date
    ),

    final as (
        select
            ed.entry_id,
            ed.fk_user_id,
            ed.exercise_id as fk_exercise_id,
            ed.session_id as fk_session_id,
            ed.fk_date_id,
            ed.weight_kg,
            ed.volumen_kg,
            ed.estimated_1rm,
            (estimated_1rm - weight_kg) as diff_weight_vs_1rm,
            ed.session_goal,
            case
                when estimated_1rm > 0 and weight_kg / estimated_1rm >= 0.80
                then 'Strength'
                when estimated_1rm > 0 and weight_kg / estimated_1rm >= 0.60
                then 'Hypertrophy'
                when estimated_1rm > 0
                then 'Endurance'
                else 'Unknown'
            end as intensity_category,
            ed.session_date,
            wv.volume_kg_total_weekly,
            
            /* Volumen semanal acumulado por usuario */
            sum(wv.volume_kg_total_weekly) over (
                partition by ed.fk_user_id, date_trunc('week', ed.session_date)
            ) as total_weekly_volume_per_user,

            /* Ranking de volumen semanal por usuario */
            rank() over (
                partition by date_trunc('week', ed.session_date)
                order by wv.volume_kg_total_weekly desc
            ) as weekly_volume_rank,

        from exercise_data ed
        left join weekly_volume wv 
            on ed.session_id = wv.session_id 
            and ed.fk_user_id = wv.fk_user_id
            and ed.session_date = wv.session_date
    )

select *
from final