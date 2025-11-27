{{ config(materialized="table") }}


with
    muscle_activation_base as (
        select
            ma.exercise_id as fk_exercise_id,
            ma.fk_muscle_id as fk_muscle_id_raw,
            ma.activation_score,
            fep.fk_user_id as fk_user_id,
            fep.entry_id as fk_entry_id,
            ds.session_id
        from {{ ref("stg_workout_data__muscle_activation_estimate") }} ma
        left join {{ ref("dim_exercise") }} de on ma.exercise_id = de.exercise_id
        left join
            {{ ref("fact_exercise_performance") }} fep
            on de.exercise_id = fep.fk_exercise_id
        left join {{ ref("dim_session") }} ds on fep.fk_session_id = ds.session_id
        where
            fep.fk_user_id is not null
            and ma.exercise_id is not null
            and ma.fk_muscle_id is not null
            and ds.session_id is not null
    ),

    muscle_mapped as (
        select
            mab.fk_exercise_id,
            dmg.muscle_id as fk_muscle_id,
            dmg.muscle_name,
            mab.activation_score,
            mab.fk_user_id,
            mab.fk_entry_id
        from muscle_activation_base mab
        left join
            {{ ref("dim_muscle_group") }} dmg on mab.fk_muscle_id_raw = dmg.muscle_id
    ),

    activation_stats as (
        select
            fk_muscle_id,
            fk_exercise_id,
            round(avg(activation_score), 3) as avg_activation,
            count(*) as total_measures,
            count(distinct fk_user_id) as unique_users
        from muscle_mapped
        group by fk_muscle_id, fk_exercise_id
        having count(*) >= 3
    ),

    ranked_exercises as (
        select
            fk_muscle_id,
            fk_exercise_id,
            avg_activation,
            total_measures,
            unique_users,
            row_number() over (
                partition by fk_muscle_id
                order by avg_activation desc, total_measures desc
            ) as muscle_ranked
        from activation_stats
    )

select
    re.fk_muscle_id,
    mm.fk_entry_id,
    re.fk_exercise_id,
    dmg.muscle_name,
    de.exercise_name,
    re.avg_activation,
    re.total_measures,
    re.unique_users,
    re.muscle_ranked,
    case
        when re.avg_activation >= 0.8
        then 'Very High Activation'
        when re.avg_activation >= 0.6
        then 'High Activation'
        when re.avg_activation >= 0.4
        then 'Medium Activation'
        when re.avg_activation >= 0.2
        then 'Low Activation'
        else 'Very Low Activation'
    end as activation_level
from ranked_exercises re
left join {{ ref("dim_muscle_group") }} dmg on re.fk_muscle_id = dmg.muscle_id
left join {{ ref("dim_exercise") }} de on re.fk_exercise_id = de.exercise_id
left join muscle_mapped mm on mm.fk_exercise_id = re.fk_exercise_id
where muscle_ranked <= 10
order by re.fk_muscle_id, re.muscle_ranked
