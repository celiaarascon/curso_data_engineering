{% test activation_data_validation(model) %}

-- Devuelve filas cuando el dato es inválido
select *
from {{ model }}
where activation_level < 0
   or activation_level > 1

{% endtest %}
