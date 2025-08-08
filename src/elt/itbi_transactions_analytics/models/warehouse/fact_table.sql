{{ config(
    materialized='table',
    indexes=[
        {'columns': ['id_fato'], 'unique': true, 'type': 'btree'},
        {'columns': ['id_tempo']},
        {'columns': ['id_imovel']},
        {'columns': ['id_construcao']},
        {'columns': ['id_comercial']}
    ]
) }}

WITH stg_data AS (
    SELECT *
    FROM {{ ref('stg_database') }}
    WHERE id_transacao IS NOT NULL
    AND cod_logradouro IS NOT NULL
    AND numero IS NOT NULL
    AND complemento IS NOT NULL
    AND data_transacao IS NOT NULL
    AND tipo_imovel IS NOT NULL
    AND tipo_ocupacao IS NOT NULL
    AND valor_avaliacao IS NOT NULL
    AND valores_financiados_sfh IS NOT NULL
    AND tipo_construcao IS NOT NULL
    AND padrao_acabamento IS NOT NULL
    AND estado_conservacao IS NOT NULL
    AND quantidade_pavimentos IS NOT NULL
    AND area_terreno IS NOT NULL
    AND area_construida IS NOT NULL
    AND ano_construcao IS NOT NULL
    AND fracao_ideal IS NOT NULL
),

joined_dimensions AS (
    SELECT
        sd.*,
        dl.id_localizacao,
        dt.data_transacao AS id_tempo,
        di.id_imovel,
        dc.id_construcao,
        dcom.id_comercial
    FROM stg_data sd
    LEFT JOIN {{ ref('dim_localizacao')}} dl
        ON sd.cod_logradouro = dl.cod_logradouro
        AND sd.numero = dl.numero
        AND sd.complemento = dl.complemento
    LEFT JOIN {{ ref('dim_tempo') }} dt
        ON CAST(sd.data_transacao AS DATE) = dt.data_transacao
    LEFT JOIN {{ ref('dim_imovel') }} di
        ON sd.tipo_imovel = di.tipo_imovel
        AND sd.tipo_ocupacao = di.tipo_ocupacao
        AND sd.lixo_organico = di.lixo_organico
    LEFT JOIN {{ ref('dim_construcao') }} dc
        ON sd.tipo_construcao = dc.tipo_construcao
        AND sd.padrao_acabamento = dc.padrao_acabamento
        AND sd.estado_conservacao = dc.estado_conservacao
        AND sd.quantidade_pavimentos = dc.quantidade_pavimentos 
        AND sd.area_terreno = dc.area_terreno
        AND sd.area_construida = dc.area_construida
        AND sd.ano_construcao = dc.ano_construcao 
        AND sd.fracao_ideal = dc.fracao_ideal
    LEFT JOIN {{ ref('dim_comercial') }} dcom
        ON sd.valor_avaliacao = dcom.valor_avaliacao
        AND sd.valores_financiados_sfh = dcom.valores_financiados_sfh
)

SELECT
    id_transacao AS id_fato,
    id_localizacao,
    id_tempo,
    id_imovel,
    id_construcao,
    id_comercial,
    CURRENT_TIMESTAMP AS loaded_at
FROM joined_dimensions