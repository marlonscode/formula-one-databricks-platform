{% macro safe_cast(column, target_type) %}
    try_cast({{ column }} as {{ target_type }})
{% endmacro %}