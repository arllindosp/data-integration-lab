# ETL Pipeline Analysis - Debug Version
# Extracted from Jupyter Notebook for clean debugging environment

# ============================================================================
# IMPORTS AND SETUP
# ============================================================================

# Importing libraries required to clean, standardize, and prepare the dataset for further analysis.
import numpy as np
import pandas as pd
import zipfile
import os
from datetime import datetime
import gc
import time

# Start timing
start_time = time.time()

print("🔧 ETL PIPELINE DEBUG VERSION")
print("=" * 50)
print(f"   • Script started at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")

# ============================================================================
# DIRECTORY SETUP
# ============================================================================

# Define the directory path where datasets will be stored
dataset_directory = "datasets"

# Create the directory if it doesn't exist, avoiding errors if it already exists
os.makedirs(dataset_directory, exist_ok=True)

print(f"   • Dataset directory: {dataset_directory}")

# ============================================================================
# MEMORY CLEANUP (adapted for Python script)
# ============================================================================

# Note: In a Python script, we don't need aggressive memory cleanup like in Jupyter
# But we can still ensure clean variable state

print("\n🧹 INITIALIZING CLEAN ENVIRONMENT")
print("=" * 50)

# Force garbage collection to start clean
gc.collect()
print("   • Initial garbage collection completed")

# ============================================================================
# DATASET CONFIGURATION
# ============================================================================

# Define URLs as a simple list to avoid any dictionary issues
dataset_info = [
    ("2023", "http://dados.recife.pe.gov.br/dataset/28e3e25e-a9a7-4a9f-90a8-bb02d09cbc18/resource/d0c08a6f-4c27-423c-9219-8d13403816f4/download/itbi_2023.csv"),
    ("2024", "http://dados.recife.pe.gov.br/dataset/28e3e25e-a9a7-4a9f-90a8-bb02d09cbc18/resource/a36d548b-d705-496a-ac47-4ec36f068474/download/itbi_2024.csv"),
    ("2025", "http://dados.recife.pe.gov.br/dataset/28e3e25e-a9a7-4a9f-90a8-bb02d09cbc18/resource/5b582147-3935-459a-bbf7-ee623c22c97b/download/itbi_2025.csv")
]

print("\n🏠 LOADING ITBI DATASETS FROM RECIFE")
print("=" * 50)
print(f"   • Target datasets: {len(dataset_info)}")

# ============================================================================
# DATA LOADING PHASE
# ============================================================================

# Store dataframes in a simple list instead of dictionary
loaded_dataframes = []
loaded_years = []

# Load each dataset one by one
for year_str, csv_url in dataset_info:
    print(f"\n📅 Loading ITBI {year_str} data...")
    print(f"   • URL: {csv_url}")
    
    try:
        # BREAKPOINT: You can set a debugger breakpoint here
        # Load data with explicit parameters
        current_df = pd.read_csv(csv_url, sep=';', encoding='utf-8')
        
        # BREAKPOINT: Check data after loading
        print(f"   • Raw data loaded: {len(current_df):,} records")
        
        # Add year column
        current_df['year'] = int(year_str)
        
        # BREAKPOINT: Check data after year column addition
        print(f"   • Year column added: {current_df['year'].unique()}")
        
        # Append to lists
        loaded_dataframes.append(current_df)
        loaded_years.append(year_str)
        
        print(f"   ✅ Success: {len(current_df):,} records, {len(current_df.columns)} columns")
        
        # Explicitly delete the temporary dataframe reference (not the data in the list)
        del current_df
        
        # BREAKPOINT: Verify list contents
        print(f"   • Total dataframes in list: {len(loaded_dataframes)}")
        
    except Exception as error:
        print(f"   ❌ Error loading {year_str} data: {error}")
        import traceback
        traceback.print_exc()

# ============================================================================
# VERIFICATION PHASE
# ============================================================================

print(f"\n🔍 VERIFICATION")
print("-" * 20)
print(f"   • Total datasets loaded: {len(loaded_dataframes)}")
print(f"   • Years loaded: {loaded_years}")

# Debug: Print detailed info about each dataframe
for i, df in enumerate(loaded_dataframes):
    year = loaded_years[i]
    print(f"   • DataFrame {i} ({year}): {len(df):,} records, year column: {df['year'].unique()}")

# ============================================================================
# COMBINATION PHASE
# ============================================================================

# Only proceed if we have exactly 3 datasets
if len(loaded_dataframes) == 3:
    print(f"\n🔗 COMBINING DATASETS")
    print("-" * 30)
    
    # BREAKPOINT: Before combination
    print(f"   • About to combine {len(loaded_dataframes)} dataframes")
    
    # Combine dataframes
    final_df = pd.concat(loaded_dataframes, ignore_index=True)
    
    # BREAKPOINT: After combination
    print(f"   • Combined dataframe created: {len(final_df):,} records")
    
    # Clear the list to free memory
    loaded_dataframes.clear()
    
    print(f"\n📊 FINAL DATASET SUMMARY")
    print("=" * 30)
    print(f"   • Total records: {len(final_df):,}")
    print(f"   • Total columns: {len(final_df.columns)}")
    print(f"   • Years included: {sorted(final_df['year'].unique())}")
    print(f"   • Memory usage: {final_df.memory_usage(deep=True).sum() / 1024**2:.2f} MB")
    
    # Records by year
    print(f"\n📈 Records by year:")
    records_by_year = final_df['year'].value_counts().sort_index()
    for year_num, record_count in records_by_year.items():
        print(f"   • {year_num}: {record_count:,} records")
    
    # Sample data
    print(f"\n📋 Sample data (first 3 rows):")
    sample_columns = ['year', 'bairro', 'tipo_imovel', 'valor_avaliacao', 'data_transacao']
    
    # Check which columns actually exist
    available_columns = [col for col in sample_columns if col in final_df.columns]
    if available_columns:
        print(final_df[available_columns].head(3))
    else:
        print("   Sample columns not found. Available columns:")
        print(f"   {list(final_df.columns[:10])}")  # Show first 10 columns
    
    # Store final dataframe in standard variable name
    df = final_df
    
    # Success flag
    etl_success = True
    
else:
    print(f"\n❌ ERROR: Expected exactly 3 datasets, but loaded {len(loaded_dataframes)}")
    print("   Cannot proceed with data combination.")
    etl_success = False

# ============================================================================
# FINAL STATUS
# ============================================================================

print(f'\n✅ Directory "{dataset_directory}" is ready for use.')

if etl_success:
    print("✅ ETL Extract phase completed successfully!")
    
    # Calculate execution time
    end_time = time.time()
    execution_time = end_time - start_time
    
    print(f"\n🎯 EXECUTION SUMMARY")
    print("-" * 25)
    print(f"   • Total execution time: {execution_time:.2f} seconds")
    print(f"   • Final dataset variable: 'df' ({len(df):,} records)")
    print(f"   • Memory footprint: {df.memory_usage(deep=True).sum() / 1024**2:.1f} MB")
    print(f"   • Ready for analysis!")
    
else:
    print("❌ ETL Extract phase failed - check errors above")

print(f"\n🔧 DEBUG SESSION COMPLETED")
print(f"   • End time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
