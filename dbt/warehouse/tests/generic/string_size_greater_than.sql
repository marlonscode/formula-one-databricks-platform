{% test string_size_greater_than(model, column_name, min_length) %}
select *
from {{ model }}
where length({{ column_name }}) <= {{ min_length }}
{% endtest %}