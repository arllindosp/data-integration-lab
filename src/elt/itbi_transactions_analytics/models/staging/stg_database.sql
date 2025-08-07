
{{ config(materialized='view') }}

-- Clean staging model using master macro
-- Applies all transformations: renaming, removing redundant columns, and type conversions
-- Equivalent to complete Python pipeline:
--   staging_dataset = rename_sfh_column(staging_dataset) 
--   staging_dataset = remove_redundant_geographic_columns(staging_dataset)
--   staging_dataset = convert_to_appropriate_types(staging_dataset)

select {{ 
    apply_all_staging_transformations() 
}}
from {{ source('raw_itbi', 'itbi_consolidado') }}