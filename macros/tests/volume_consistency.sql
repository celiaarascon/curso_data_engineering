{% test volume_consistency(model, volume_column='volume_kg', sets_column='sets', reps_column='reps', weight_column='weight_kg', tolerance=0.01) %}

with source_rows as (
    select *
    from {{ model }}
),

mismatches as (
    select
      *,
      abs( ({{ sets_column }} * {{ reps_column }} * {{ weight_column }}) - {{ volume_column }} ) as diff,
      case when {{ sets_column }} is null or {{ reps_column }} is null or {{ weight_column }} is null or {{ volume_column }} is null then true else false end as has_null
    from source_rows
)

select *
from mismatches
where has_null = true
   or diff > (coalesce({{ tolerance }}, 0) * nullif({{ sets_column }} * {{ reps_column }} * {{ weight_column }},0))

{% endtest %}
