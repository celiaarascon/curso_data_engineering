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
            /* Absolute progression */
            weight_kg - first_value(weight_kg) over (
                partition by fk_user_id, exercise_id order by session_date
            ) as weight_change_from_start,

            /* Weeks since start */
            nullif(
                datediff(
                    'week',
                    first_value(session_date) over (
                        partition by fk_user_id, exercise_id order by session_date
                    ),
                    session_date
                ),
                0
            ) as weeks_since_start,

            /* Weekly progress rate with 1 decimal */
            case
                when
                    nullif(
                        datediff(
                            'week',
                            first_value(session_date) over (
                                partition by fk_user_id, exercise_id
                                order by session_date
                            ),
                            session_date
                        ),
                        0
                    )
                    is null
                then null
                else
                    round(
                        (
                            weight_kg - first_value(weight_kg) over (
                                partition by fk_user_id, exercise_id
                                order by session_date
                            )
                        ) / nullif(
                            datediff(
                                'week',
                                first_value(session_date) over (
                                    partition by fk_user_id, exercise_id
                                    order by session_date
                                ),
                                session_date
                            ),
                            0
                        ),
                        1
                    )
            end as weekly_progress_rate

        from exercise_data ed
    )

select *
from final
