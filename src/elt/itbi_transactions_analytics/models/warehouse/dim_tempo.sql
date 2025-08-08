{{ config(
    materialized='table',
    indexes=[
        {'columns': ['data_transacao'], 'unique': true, 'type': 'btree'},
        {'columns': ['ano']},
        {'columns': ['mes']},
        {'columns': ['trimestre']},
        {'columns': ['dia_semana']}
    ]
) }}

WITH source_data AS (
    SELECT
        data_transacao
    FROM {{ ref('stg_database') }}
    WHERE data_transacao IS NOT NULL
),

distinct_dates AS (
    SELECT
        CAST(data_transacao AS DATE) as data_transacao
    FROM source_data
    GROUP BY 1
),

final AS (
    SELECT
        dd.data_transacao as data_transacao,
        EXTRACT(YEAR FROM dd.data_transacao) AS ano,
        EXTRACT(MONTH FROM dd.data_transacao) AS mes,
        EXTRACT(QUARTER FROM dd.data_transacao) AS trimestre,
        EXTRACT(DAY FROM dd.data_transacao) AS dia,
        EXTRACT(DOW FROM dd.data_transacao) AS dia_semana,
        TO_CHAR(dd.data_transacao, 'Month') AS nome_mes,
        TO_CHAR(dd.data_transacao, 'Day') AS nome_dia_semana,
        CURRENT_TIMESTAMP AS loaded_at
    FROM distinct_dates dd
)

SELECT * FROM final
ORDER BY data_transacao