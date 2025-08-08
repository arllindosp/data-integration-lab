{{ config(
    materialized='table',
    indexes=[
        {'columns': ['id_comercial'], 'unique': true, 'type': 'btree'},
        {'columns': ['valor_avaliacao']},
        {'columns': ['valores_financiados_sfh']}
    ]
) }}

WITH distinct_commercial_attributes AS (
    SELECT DISTINCT
        valor_avaliacao,
        valores_financiados_sfh
    FROM {{ ref('stg_database') }}
),

final AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key([
            'valor_avaliacao',
            'valores_financiados_sfh'
        ]) }} AS id_comercial,
        valor_avaliacao,
        valores_financiados_sfh,
        -- Calculate ITBI: Valor_Avaliacao × 0.03 (3%)
        -- ROUND to 2 decimal places for currency precision
        ROUND(valor_avaliacao * 0.03, 2) AS valor_itbi,
        CURRENT_TIMESTAMP AS loaded_at
    FROM distinct_commercial_attributes
)

SELECT * FROM final
ORDER BY id_comercial