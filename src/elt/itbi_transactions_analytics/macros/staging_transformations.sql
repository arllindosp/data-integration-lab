{% macro apply_all_staging_transformations() %}
    -- Address fields
    trim(logradouro) as logradouro,
    numero,
    {{ convert_complemento_to_object('complemento') }},
    cod_logradouro,
    
    -- Location fields (geographic redundant columns removed)
    trim(bairro) as bairro,
    latitude,
    longitude,
    
    -- Property characteristics with all conversions applied
    ano_construcao,
    {{ convert_valor_avaliacao_to_float('valor_avaliacao') }},
    {{ convert_area_to_float('area_terreno', 10, 2) }},
    {{ convert_area_to_float('area_construida', 10, 2) }},
    {{ convert_fracao_ideal_to_float('fracao_ideal') }},
    
    -- Categorical conversions
    {{ convert_to_category_text('padrao_acabamento') }},
    {{ convert_to_category_text('tipo_construcao') }},
    {{ convert_to_category_text('tipo_ocupacao') }},
    {{ convert_to_category_text('estado_conservacao') }},
    {{ convert_to_category_text('tipo_imovel') }},
    
    -- SFH renamed and converted in one step
    {{ convert_valores_financiados_sfh_from_source('sfh', 'valores_financiados_sfh') }},
    
    -- Date conversion
    {{ convert_data_transacao_to_timestamp('data_transacao') }},
    
    -- Year conversion
    ano::integer as ano,
    
    -- Audit timestamp
    current_timestamp as loaded_at
{% endmacro %}