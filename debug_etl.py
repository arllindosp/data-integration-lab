# Temporary Python file for debugging ETL pipeline
# Converted from etl_pipeline_analysis.ipynb

# Import libraries
import numpy as np
import pandas as pd
import zipfile
import os
from datetime import datetime
import time

start_time = time.time()

# Define the directory path where datasets will be stored
dataset_directory = "datasets"
os.makedirs(dataset_directory, exist_ok=True)

# URLs for ITBI datasets from Recife (2023, 2024, 2025)
urls = {
    '2023': "http://dados.recife.pe.gov.br/dataset/28e3e25e-a9a7-4a9f-90a8-bb02d09cbc18/resource/d0c08a6f-4c27-423c-9219-8d13403816f4/download/itbi_2023.csv",
    '2024': "http://dados.recife.pe.gov.br/dataset/28e3e25e-a9a7-4a9f-90a8-bb02d09cbc18/resource/a36d548b-d705-496a-ac47-4ec36f068474/download/itbi_2024.csv",
    '2025': "http://dados.recife.pe.gov.br/dataset/28e3e25e-a9a7-4a9f-90a8-bb02d09cbc18/resource/5b582147-3935-459a-bbf7-ee623c22c97b/download/itbi_2025.csv"
}

print("🏠 LOADING ITBI DATASETS FROM RECIFE")
print("=" * 50)

# Dictionary to store individual dataframes
dataframes = {}
total_records = 0

# Load each dataset (sorted by year for consistent order)
for year in sorted(urls.keys()):
    url = urls[year]
    print(f"\n📅 Loading ITBI {year} data...")
    
    # ADD BREAKPOINT HERE ⬇️ (Click on line number 35)
    try:
        # Error fix: The CSV files use semicolon (;) as delimiter instead of comma (,)
        df_year = pd.read_csv(url, sep=';', encoding='utf-8')
        
        # ADD BREAKPOINT HERE ⬇️ (Click on line number 40)
        df_year['year'] = int(year)
        
        dataframes[year] = df_year
        total_records += len(df_year)
        
        print(f"   ✅ Success: {len(df_year):,} records, {len(df_year.columns)} columns")
        
        # DEBUG: Print what's being added
        print(f"   🔍 DEBUG: Added {year} with {len(df_year)} records to dataframes")
        print(f"   🔍 DEBUG: dataframes now has keys: {list(dataframes.keys())}")
        
    except Exception as e:
        print(f"   ❌ Error loading {year} data: {e}")

# Combine all datasets into one DataFrame
if dataframes:
    print(f"\n🔗 COMBINING DATASETS")
    print("-" * 30)
    
    # ADD BREAKPOINT HERE ⬇️ (Click on line number 55)
    df = pd.concat(dataframes.values(), ignore_index=True)
    
    print(f"📊 FINAL DATASET SUMMARY")
    print("=" * 30)
    print(f"   • Total records: {len(df):,}")
    print(f"   • Total columns: {len(df.columns)}")
    print(f"   • Years included: {sorted(dataframes.keys())}")
    
    # Records by year
    print(f"\n📈 Records by year:")
    year_counts = df['year'].value_counts().sort_index()
    for year, count in year_counts.items():
        print(f"   • {year}: {count:,} records")
        
else:
    print("\n❌ No datasets were loaded successfully!")

print(f'\n✅ Directory "{dataset_directory}" is ready for use.')
