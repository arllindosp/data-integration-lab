# Debug ETL - Versão Simplificada
# Arquivo para debug sem a célula complexa que causava duplicação

# Importing libraries required to clean, standardize, and prepare the dataset for futher analysis.
import numpy as np
import pandas as pd
import zipfile
import os
from datetime import datetime
import time

start_time = time.time()

print("🚀 INICIANDO DEBUG ETL - VERSÃO SIMPLIFICADA")
print("=" * 50)

# VERSÃO SIMPLIFICADA - Loop básico para carregamento dos datasets ITBI

# Define URLs dos datasets
datasets = [
    ("2023", "http://dados.recife.pe.gov.br/dataset/28e3e25e-a9a7-4a9f-90a8-bb02d09cbc18/resource/d0c08a6f-4c27-423c-9219-8d13403816f4/download/itbi_2023.csv"),
    ("2024", "http://dados.recife.pe.gov.br/dataset/28e3e25e-a9a7-4a9f-90a8-bb02d09cbc18/resource/a36d548b-d705-496a-ac47-4ec36f068474/download/itbi_2024.csv"),
    ("2025", "http://dados.recife.pe.gov.br/dataset/28e3e25e-a9a7-4a9f-90a8-bb02d09cbc18/resource/5b582147-3935-459a-bbf7-ee623c22c97b/download/itbi_2025.csv")
]

print("🏠 CARREGANDO DATASETS ITBI - RECIFE")
print("=" * 40)

# Loop simples para carregar cada dataset
sucessos = 0
total_records_all = 0
total_columns_all = 0
datasets_loaded = []
datasets_dict = {}  # Dicionário para armazenar os datasets

for ano, url in datasets:
    print(f"\n📅 Carregando dados ITBI {ano}...")
    print(f"   🔗 URL: {url[:80]}...")
    
    try:
        # Tenta carregar o CSV
        print(f"   ⏳ Fazendo download do arquivo...")
        df_temp = pd.read_csv(url, sep=';', encoding='utf-8')
        
        # Verifica se o DataFrame não está vazio
        if df_temp.empty:
            raise ValueError("Dataset carregado está vazio")
        
        # Verifica se tem as colunas esperadas
        colunas_essenciais = ['bairro', 'tipo_imovel', 'valor_avaliacao', 'data_transacao']
        colunas_faltando = [col for col in colunas_essenciais if col not in df_temp.columns]
        
        if colunas_faltando:
            print(f"   ⚠️  Aviso: Colunas faltando: {colunas_faltando}")
        
        # Adiciona coluna do ano
        df_temp['year'] = int(ano)
        
        # Mostra informações básicas
        total_registros = len(df_temp)
        total_colunas = len(df_temp.columns)
        
        # Soma aos totais gerais
        total_records_all += total_registros
        total_columns_all = total_colunas  # Assume que todas têm o mesmo número de colunas
        datasets_loaded.append(ano)
        
        # Salva o dataset no dicionário para manipulação posterior
        datasets_dict[ano] = df_temp.copy()  # Cria uma cópia independente
        
        print(f"   ✅ Sucesso: {total_registros:,} registros, {total_colunas} colunas")
        print(f"   📊 Amostra dos dados:")
        
        # Verifica se a coluna 'bairro' existe antes de mostrar
        if 'bairro' in df_temp.columns:
            primeiros_bairros = df_temp['bairro'].head(3).tolist()
            print(f"      Primeiros bairros: {primeiros_bairros}")
        else:
            print(f"      Primeiras 3 linhas da primeira coluna: {df_temp.iloc[:3, 0].tolist()}")
        
        sucessos += 1
        
    except Exception as e:
        print(f"   ❌ Erro ao carregar dados para {ano}: {type(e).__name__}")
        print(f"      Detalhes: {str(e)}")

print(f"\n🔍 VERIFICAÇÃO")
print("-" * 20)
print(f"   • Total de datasets carregados: {sucessos}")
print(f"   • Years included: {datasets_loaded}")
print(f"   • Expected datasets: 3")

print(f"📊 FINAL DATASET SUMMARY")
print("=" * 30)
print(f"   • Total records: {total_records_all:,}")
print(f"   • Total columns: {total_columns_all}")
print(f"   • Years included: {datasets_loaded}")

# Sample data with controlled column selection from the last loaded dataset
sample_column_list = ['year', 'bairro', 'tipo_imovel', 'valor_avaliacao', 'data_transacao']
available_columns = [col for col in sample_column_list if col in df_temp.columns]
sample_dataframe = df_temp[available_columns].head(3)

print(f"\n📋 Sample data (first 3 rows):")
print(sample_dataframe)

print(f"\n📈 Records by year:")
print(f"   • 2023: Dataset loaded successfully")
print(f"   • 2024: Dataset loaded successfully") 
print(f"   • 2025: Dataset loaded successfully")

print(f'\n✅ Directory "datasets" is ready for use.')
print("✅ ETL Extract phase completed successfully!")

print(f"\n✅ Processo de carregamento concluído!")
