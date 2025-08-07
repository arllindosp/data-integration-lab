{{ config(materialized='table') }}

SELECT 
    -- Chave primária única
    ROW_NUMBER() OVER (ORDER BY data_transacao, cod_logradouro, numero, valor_avaliacao_limpo) AS transacao_id,
    
    -- Chaves estrangeiras para as dimensões
    t.tempo_id,
    l.localizacao_id,
    i.imovel_id,
    
    -- Dados originais importantes
    ic.data_transacao,
    ic.cod_logradouro,
    ic.numero,
    ic.complemento,
    ic.fonte,
    ic.ano_construcao,
    ic.bairro,
    ic.logradouro,
    ic.cidade,
    ic.uf,
    
    -- Métricas principais limpas
    CASE 
        WHEN ic.valor_avaliacao IS NOT NULL AND ic.valor_avaliacao != '' 
        THEN REPLACE(ic.valor_avaliacao, ',', '.')::numeric 
        ELSE NULL 
    END AS valor_avaliacao,
    
    CASE 
        WHEN ic.valores_financiados_sfh IS NOT NULL AND ic.valores_financiados_sfh != '' 
        THEN REPLACE(ic.valores_financiados_sfh, ',', '.')::numeric 
        ELSE NULL 
    END AS valores_financiados_sfh,
    
    CASE 
        WHEN ic.area_construida IS NOT NULL AND ic.area_construida != '' 
        THEN REPLACE(ic.area_construida, ',', '.')::numeric 
        ELSE NULL 
    END AS area_construida,
    
    CASE 
        WHEN ic.area_terreno IS NOT NULL AND ic.area_terreno != '' 
        THEN REPLACE(ic.area_terreno, ',', '.')::numeric 
        ELSE NULL 
    END AS area_terreno,
    
    CASE 
        WHEN ic.fracao_ideal IS NOT NULL AND ic.fracao_ideal != '' 
        THEN REPLACE(ic.fracao_ideal, ',', '.')::numeric 
        ELSE NULL 
    END AS fracao_ideal,
    
    -- Métricas calculadas
    CASE 
        WHEN REPLACE(ic.area_construida, ',', '.')::numeric > 0 
        THEN ROUND(REPLACE(ic.valor_avaliacao, ',', '.')::numeric / REPLACE(ic.area_construida, ',', '.')::numeric, 2)
        ELSE NULL
    END AS valor_por_m2_construido,
    
    CASE 
        WHEN REPLACE(ic.area_terreno, ',', '.')::numeric > 0 
        THEN ROUND(REPLACE(ic.valor_avaliacao, ',', '.')::numeric / REPLACE(ic.area_terreno, ',', '.')::numeric, 2)
        ELSE NULL
    END AS valor_por_m2_terreno,
    
    CASE 
        WHEN REPLACE(ic.valor_avaliacao, ',', '.')::numeric > 0 AND REPLACE(ic.valores_financiados_sfh, ',', '.')::numeric > 0
        THEN ROUND((REPLACE(ic.valores_financiados_sfh, ',', '.')::numeric / REPLACE(ic.valor_avaliacao, ',', '.')::numeric) * 100, 2)
        ELSE 0
    END AS percentual_financiamento,
    
    CASE 
        WHEN REPLACE(ic.area_terreno, ',', '.')::numeric > 0 AND REPLACE(ic.area_construida, ',', '.')::numeric > 0
        THEN ROUND((REPLACE(ic.area_construida, ',', '.')::numeric / REPLACE(ic.area_terreno, ',', '.')::numeric) * 100, 2)
        ELSE NULL
    END AS taxa_ocupacao,
    
    -- Idade do imóvel
    CASE 
        WHEN ic.ano_construcao IS NOT NULL AND ic.ano_construcao::int > 1900
        THEN EXTRACT(YEAR FROM ic.data_transacao::date) - ic.ano_construcao::int
        ELSE NULL
    END AS idade_imovel,
    
    -- Indicadores de negócio
    CASE 
        WHEN ic.sfh = 'Sim' OR REPLACE(ic.valores_financiados_sfh, ',', '.')::numeric > 0 
        THEN 'Financiado'
        ELSE 'À Vista'
    END AS tipo_pagamento,
    
    CASE 
        WHEN REPLACE(ic.valor_avaliacao, ',', '.')::numeric <= 200000 THEN 'Econômico'
        WHEN REPLACE(ic.valor_avaliacao, ',', '.')::numeric <= 500000 THEN 'Médio'
        WHEN REPLACE(ic.valor_avaliacao, ',', '.')::numeric <= 1000000 THEN 'Alto'
        ELSE 'Premium'
    END AS segmento_valor,
    
    -- Tipo de imóvel limpo
    ic.tipo_imovel,
    ic.tipo_construcao,
    ic.padrao_acabamento,
    ic.estado_conservacao,
    
    -- Metadados de auditoria
    CURRENT_TIMESTAMP AS created_at,
    'elt_pipeline' AS created_by
    
FROM {{ source('public', 'itbi_consolidado') }} ic

-- Joins com as dimensões usando LEFT JOIN para manter todos os registros
LEFT JOIN {{ ref('dim_tempo') }} t 
    ON ic.data_transacao::date = t.data_transacao

LEFT JOIN {{ ref('dim_localizacao') }} l 
    ON ic.cod_logradouro = l.cod_logradouro 
    AND ic.numero = l.numero

LEFT JOIN {{ ref('dim_imovel') }} i 
    ON CASE 
        WHEN UPPER(ic.tipo_imovel) LIKE '%APARTAMENTO%' THEN 'Apartamento'
        WHEN UPPER(ic.tipo_imovel) LIKE '%CASA%' THEN 'Casa'
        WHEN UPPER(ic.tipo_imovel) LIKE '%GALPAO%' OR UPPER(ic.tipo_imovel) LIKE '%GALPÃO%' THEN 'Galpão'
        WHEN UPPER(ic.tipo_imovel) LIKE '%LOJA%' THEN 'Loja'
        WHEN UPPER(ic.tipo_imovel) LIKE '%SALA%' THEN 'Sala Comercial'
        WHEN UPPER(ic.tipo_imovel) LIKE '%TERRENO%' THEN 'Terreno'
        WHEN UPPER(ic.tipo_imovel) LIKE '%COBERTURA%' THEN 'Cobertura'
        ELSE COALESCE(ic.tipo_imovel, 'Não Classificado')
    END = i.tipo_imovel_limpo
    
WHERE ic.valor_avaliacao IS NOT NULL 
  AND ic.valor_avaliacao != ''
  AND REPLACE(ic.valor_avaliacao, ',', '.')::numeric > 0
  AND ic.data_transacao IS NOT NULL
ORDER BY transacao_id
