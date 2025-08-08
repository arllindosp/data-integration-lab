-- Macro equivalent to clean_tipo_ocupacao function
{% macro clean_tipo_ocupacao(column_name) %}
    CASE 
        WHEN {{ column_name }} IS NULL THEN 'não especificado'
        WHEN LOWER(CAST({{ column_name }} AS TEXT)) LIKE '%residencial%' THEN 'Residencial'
        WHEN LOWER(CAST({{ column_name }} AS TEXT)) LIKE '%comercial%' THEN 'Comercial'
        ELSE 'não especificado'
    END
{% endmacro %}

-- Macro equivalent to parse_lixo_organico function
{% macro parse_lixo_organico(column_name) %}
    CASE 
        WHEN {{ column_name }} IS NULL THEN 'não especificado'
        WHEN LOWER(CAST({{ column_name }} AS TEXT)) LIKE '%com lixo organico%' THEN 'sim'
        WHEN LOWER(CAST({{ column_name }} AS TEXT)) LIKE '%sem lixo organico%' THEN 'não'
        ELSE 'não especificado'
    END
{% endmacro %}
