{% test has_activation(model, activation_source_name='muscule_activation_estimate_raw', activation_source_schema='workout_data') %}

with exercises as (
  select * from {{ model }}
),

activations as (
  select * from {{ source(activation_source_schema, activation_source_name) }}
)

select e.*
from exercises e
left join activations a
  on a.exercise_id = e.exercise_id
where a.exercise_id is null

{% endtest %}
