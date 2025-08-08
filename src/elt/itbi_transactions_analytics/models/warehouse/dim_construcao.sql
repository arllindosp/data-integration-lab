{{ config(
    materialized='table',
    indexes=[
        {'columns': ['id_construcao'], 'unique': true, 'type': 'btree'},
        {'columns': ['tipo_construcao']},
        {'columns': ['padrao_acabamento']},
        {'columns': ['estado_conservacao']},
        {'columns': ['ano_construcao']}
    ]
) }}

WITH distinct_construction_attributes AS (
    SELECT DISTINCT
       tipo_construcao,
       padrao_acabamento,
       estado_conservacao,
       quantidade_pavimentos,
       area_terreno,
       area_construida,
       ano_construcao,
       fracao_ideal
    FROM {{ ref('stg_database') }}
),

final AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key([
            'tipo_construcao',
            'padrao_acabamento',
            'estado_conservacao',
            'quantidade_pavimentos',
            'area_terreno',
            'area_construida',
            'ano_construcao',
            'fracao_ideal'
        ]) }} AS id_construcao,
        tipo_construcao,
        padrao_acabamento,
        estado_conservacao,
        quantidade_pavimentos, 
        area_terreno,
        area_construida,
        ano_construcao, 
        fracao_ideal,
        CURRENT_TIMESTAMP AS loaded_at
    FROM distinct_construction_attributes
)

SELECT * FROM final
ORDER BY id_construcao
