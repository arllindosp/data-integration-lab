{{ config(materialized='view') }}

-- Clean staging model with null handling in CTE
WITH null_handled AS (
    SELECT 
        *,
        {{ handle_complemento_nulls() }} AS complemento_clean
    FROM {{ source('raw_itbi', 'itbi_consolidado') }}
),
cleaned_tipo_construcao AS (
    SELECT
        *,
        {{ parse_pavimentos('tipo_construcao') }} AS quantidade_pavimentos,
        {{ clean_tipo_construcao('tipo_construcao') }} AS tipo_construcao_clean
    FROM null_handled
),
cleaned_tipo_ocupacao AS (
    SELECT
        *,
        {{ parse_lixo_organico('tipo_ocupacao') }} AS lixo_organico,
        {{ clean_tipo_ocupacao('tipo_ocupacao') }} AS tipo_ocupacao_clean
    FROM cleaned_tipo_construcao
)
SELECT 
    {{ apply_all_conversion_transformations() }}
FROM cleaned_tipo_ocupacao