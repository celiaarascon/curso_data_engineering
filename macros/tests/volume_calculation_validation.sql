{% test volume_calculation_validation(model) %}

-- Devuelve filas cuando el volumen es inválido
select *
from {{ model }}
where volume < 0

{% endtest %}
