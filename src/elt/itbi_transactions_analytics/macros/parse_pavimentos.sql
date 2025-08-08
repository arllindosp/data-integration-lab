-- dbt macro for parsing pavimentos (equivalent to parse_pavimentos function)
{% macro parse_pavimentos(column_name) %}
  CASE 
    WHEN {{ column_name }} IS NULL THEN 'não especificado'
    WHEN LOWER(CAST({{ column_name }} AS TEXT)) LIKE '%<= 4 pavimentos%' 
      OR LOWER(CAST({{ column_name }} AS TEXT)) LIKE '%<=4 pavimentos%' THEN '<= 4 pavimentos'
    WHEN LOWER(CAST({{ column_name }} AS TEXT)) LIKE '%> 4 pavimentos%' 
      OR LOWER(CAST({{ column_name }} AS TEXT)) LIKE '%>4 pavimentos%' THEN '> 4 pavimentos'
    ELSE 'não especificado'
  END
{% endmacro %}

-- dbt macro for cleaning tipo_construcao (equivalent to clean_tipo_construcao function)
{% macro clean_tipo_construcao(column_name) %}
  CASE 
    WHEN {{ column_name }} IS NULL THEN {{ column_name }}
    ELSE TRIM(
      REGEXP_REPLACE(
        REGEXP_REPLACE(
          CAST({{ column_name }} AS TEXT),
          '\s*[<>=]*\s*\d+\s*pavimentos?\s*',
          '',
          'gi'
        ),
        '\s+',
        ' ',
        'g'
      )
    )
  END
{% endmacro %}