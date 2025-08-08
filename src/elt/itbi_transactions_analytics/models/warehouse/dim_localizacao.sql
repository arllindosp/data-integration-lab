{{ config(
    materialized='table',
    indexes=[
        {'columns': ['cod_logradouro', 'numero', 'complemento'], 'unique': true},
        {'columns': ['bairro']},
        {'columns': ['logradouro']}
    ]
) }}

WITH row_numbered_locations AS (
    SELECT
        *,
        ROW_NUMBER() OVER(
            PARTITION BY cod_logradouro, numero, complemento
            ORDER BY loaded_at DESC  
        ) AS rn
    FROM {{ref('stg_database')}}
    WHERE cod_logradouro IS NOT NULL
),

unique_locations AS (
    SELECT
        cod_logradouro,
        numero,
        logradouro,
        bairro,
        latitude,
        longitude,
        complemento
    FROM row_numbered_locations
    WHERE rn = 1
),

final AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['cod_logradouro', 'numero', 'complemento']) }} as id_localizacao,
        cod_logradouro,
        numero,
        logradouro,
        bairro,
        latitude,
        longitude,
        complemento,
        current_timestamp as created_at
    FROM unique_locations
)

SELECT * FROM final