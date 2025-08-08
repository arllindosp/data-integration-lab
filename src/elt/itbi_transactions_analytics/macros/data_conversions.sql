-- macros/data_conversions.sql
-- PostgreSQL-specific data conversion macros

{% macro standardize_decimal_format(column_name) %}
    case 
        when {{ column_name }} is null then null
        else replace({{ column_name }}::text, ',', '.')::numeric
    end
{% endmacro %}

{% macro convert_valor_avaliacao_to_float(column_name='valor_avaliacao') %}
    case 
        when {{ column_name }} is null then null
        else replace({{ column_name }}::text, ',', '.')::numeric(15,2)
    end as {{ column_name }}
{% endmacro %}

{% macro convert_area_to_float(column_name, precision=10, scale=2) %}
    case 
        when {{ column_name }} is null then null
        else replace({{ column_name }}::text, ',', '.')::numeric({{ precision }}, {{ scale }})
    end as {{ column_name }}
{% endmacro %}

{% macro convert_fracao_ideal_to_float(column_name='fracao_ideal') %}
    case 
        when {{ column_name }} is null then null
        else replace({{ column_name }}::text, ',', '.')::numeric(10,6)
    end as {{ column_name }}
{% endmacro %}

{% macro convert_data_transacao_to_timestamp(column_name='data_transacao') %}
    case 
        when {{ column_name }} is null then null
        when {{ column_name }} ~ '^\d{2}/\d{2}/\d{4}' then 
            to_date({{ column_name }}, 'DD/MM/YYYY')
        else 
            {{ column_name }}::date
    end as {{ column_name }}
{% endmacro %}

{% macro convert_valores_financiados_sfh_to_float(column_name='valores_financiados_sfh') %}
    case 
        when {{ column_name }} is null then null
        else replace({{ column_name }}::text, ',', '.')::numeric(15,2)
    end as {{ column_name }}
{% endmacro %}

{% macro convert_valores_financiados_sfh_from_source(source_column='sfh', target_column='valores_financiados_sfh') %}
    case 
        when {{ source_column }} is null then null
        else replace({{ source_column }}::text, ',', '.')::numeric(15,2)
    end as {{ target_column }}
{% endmacro %}

{% macro convert_complemento_to_object(column_name='complemento') %}
    case 
        when trim({{ column_name }}) = '' then null 
        else trim({{ column_name }})::text 
    end as {{ column_name }}
{% endmacro %}

{% macro convert_to_category_text(column_name) %}
    trim({{ column_name }})::text as {{ column_name }}
{% endmacro %}

{% macro remove_redundant_geographic_columns() %}
    -- This macro just documents which columns are removed
    -- cidade and uf are not selected (redundant: only Recife, PE)
{% endmacro %}