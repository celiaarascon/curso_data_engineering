{% test not_future_date(model, column_name='session_date') %}

select *
from {{ model }}
where {{ column_name }}::timestamp > current_timestamp

{% endtest %}
