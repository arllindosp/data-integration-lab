{% macro handle_complemento_nulls() %}
  coalesce(complemento, 'não especificado')
{% endmacro %}