{% macro apply_all_conversion_transformations() %}

 trim(logradouro) as logradouro,
 numero,
 {{ convert_complemento_to_object('complemento_clean, complemento')}},
 cod_logradouro,
 trim(bairro) as bairro,
 latitude,
 longitude,
 ano_construcao,
 {{ convert_valor_avaliacao_to_float('valor_avaliacao') }},
 {{ convert_area_to_float('area_terreno', 10, 2) }},
 {{ convert_area_to_float('area_construida', 10, 2) }},
 {{ convert_fracao_ideal_to_float('fracao_ideal') }},
 {{ convert_to_category_text('padrao_acabamento', 'padrao_acabamento') }},
 {{ convert_to_category_text('tipo_construcao_clean', 'tipo_construcao') }},
 {{ convert_to_category_text('tipo_ocupacao_clean', 'tipo_ocupacao') }},
 {{ convert_to_category_text('estado_conservacao', 'estado_conservacao') }},
 {{ convert_to_category_text('tipo_imovel', 'tipo_imovel')}},
 {{ convert_valores_financiados_sfh_from_source('sfh', 'valores_financiados_sfh') }},
 {{ convert_data_transacao_to_timestamp('data_transacao') }},
 ano::integer as ano,
 current_timestamp as loaded_at
{% endmacro %}