{{ config(
    materialized='table',
    indexes=[
        {'columns': ['id_imovel'], 'unique': true, 'type': 'btree'},
        {'columns': ['tipo_imovel']},
        {'columns': ['tipo_ocupacao']},
        {'columns': ['lixo_organico']}
    ]
) }}

WITH distinct_properties AS (
    SELECT DISTINCT
        tipo_imovel,
        tipo_ocupacao,
        lixo_organico
    FROM {{ ref('stg_database') }}
    WHERE
        tipo_imovel IS NOT NULL AND
        tipo_ocupacao IS NOT NULL
),

final AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key([
            'tipo_imovel',
            'tipo_ocupacao',
            'lixo_organico'
        ]) }} AS id_imovel,
        tipo_imovel,
        tipo_ocupacao,
        lixo_organico, 
        CURRENT_TIMESTAMP AS loaded_at
    FROM distinct_properties
)

SELECT * FROM final
ORDER BY id_imovel