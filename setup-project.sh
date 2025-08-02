#!/bin/bash

# ============================================
# Projeto: Estrutura Profissional ITBI Recife
# Autor: Gerado por ChatGPT
# Uso: bash setup_projeto.sh
# ============================================

set -e

echo -e "\n🏗️ CRIANDO ESTRUTURA PROFISSIONAL DO PROJETO"
echo "============================================="

# Diretório raiz do projeto
mkdir -p projeto-integracao-itbi
cd projeto-integracao-itbi

# Estrutura de diretórios
mkdir -p data/{raw,processed,external}
mkdir -p notebooks
mkdir -p src/{etl,elt,analysis,utils}
mkdir -p docs/diagramas
mkdir -p tests
mkdir -p scripts
mkdir -p config
mkdir -p results/{datasets,analysis,visualizations,quality}

# Verificar se Python está disponível e criar ambiente virtual
echo -e "\n🐍 Verificando instalação do Python..."

# Função para testar Python real (não alias do Microsoft Store)
test_python() {
    local cmd=$1
    # Testa se é uma instalação real do Python
    local version_output=$($cmd --version 2>&1)
    if [[ $? -eq 0 ]] && [[ "$version_output" =~ ^Python\ [0-9] ]]; then
        echo "✅ Python encontrado: $version_output"
        return 0
    else
        return 1
    fi
}

# Tentar diferentes comandos Python
PYTHON_CMD=""

echo "🔍 Procurando Python instalado..."

# Lista de comandos para tentar
commands=("python3" "python" "py" "/c/Python*/python.exe")

for cmd in "${commands[@]}"; do
    echo "  Testando: $cmd"
    if test_python "$cmd" 2>/dev/null; then
        PYTHON_CMD="$cmd"
        break
    fi
done

# Se não encontrou, procurar em locais comuns
if [[ -z "$PYTHON_CMD" ]]; then
    echo "🔍 Procurando em diretórios comuns..."
    
    # Locais comuns do Python no Windows
    common_paths=(
        "/c/Users/$USER/AppData/Local/Programs/Python"
        "/c/Python3*"
        "/c/Program Files/Python*"
        "/c/Program Files (x86)/Python*"
    )
    
    for base_path in "${common_paths[@]}"; do
        for python_dir in $(ls $base_path 2>/dev/null); do
            if [[ -f "$python_dir/python.exe" ]]; then
                if test_python "$python_dir/python.exe"; then
                    PYTHON_CMD="$python_dir/python.exe"
                    break 2
                fi
            fi
        done
    done
fi

if [[ -z "$PYTHON_CMD" ]]; then
    echo ""
    echo "❌ PYTHON NÃO ENCONTRADO!"
    echo "============================================="
    echo "� SOLUÇÃO: Instale o Python primeiro"
    echo ""
    echo "📥 OPÇÃO 1: Download oficial (Recomendado)"
    echo "   1. Acesse: https://python.org/downloads"
    echo "   2. Baixe Python 3.10+ para Windows"
    echo "   3. ✅ IMPORTANTE: Marque 'Add Python to PATH'"
    echo "   4. Reinstale e reinicie o terminal"
    echo ""
    echo "� OPÇÃO 2: Via Windows Package Manager"
    echo "   winget install Python.Python.3.11"
    echo ""
    echo "📥 OPÇÃO 3: Via Chocolatey"
    echo "   choco install python"
    echo ""
    echo "⚠️  EVITE instalar do Microsoft Store (pode causar problemas)"
    echo ""
    echo "🔄 Após instalar, execute novamente: bash setup-project.sh"
    exit 1
fi

echo "✅ Usando Python: $PYTHON_CMD"
$PYTHON_CMD -m venv .venv

# Ativação do ambiente virtual para Windows
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    source .venv/Scripts/activate
else
    source .venv/bin/activate
fi

# requirements.txt com bibliotecas necessárias
cat > requirements.txt <<EOF
# Core data processing (versões compatíveis com Python 3.13)
pandas>=2.1.0
numpy>=1.24.0

# Visualization
matplotlib>=3.7.0
seaborn>=0.12.0

# Jupyter
jupyter>=1.0.0
notebook>=7.0.0

# Development
pytest>=7.4.0

# Utility
tqdm>=4.66.0
python-dotenv>=1.0.0
pyyaml>=6.0.0
EOF

# Instalação com upgrade do pip e versões compatíveis
echo -e "\n📦 Atualizando pip e instalando bibliotecas..."
pip install --upgrade pip
pip install --only-binary=all --no-cache-dir -r requirements.txt

# .gitignore padrão
cat > .gitignore <<EOF
.venv/
__pycache__/
*.py[cod]
.ipynb_checkpoints/
data/raw/
data/external/
*.db
*.sqlite*
config/*.yaml
config/*.json
results/quality/*.json
results/quality/*.txt
EOF

# README básico
cat > README.md <<EOF
# Projeto Integração de Dados ITBI - Recife

Este projeto tem como objetivo implementar pipelines de integração de dados (ETL e ELT) do ITBI da cidade do Recife entre 2023 e 2025, incluindo análises e visualizações.

## Execução

```bash
source .venv/bin/activate
python scripts/run_etl.py
```

Estrutura e requisitos definidos automaticamente pelo script `setup_projeto.sh`.
EOF

# Arquivos __init__.py para tornar os diretórios módulos Python
for dir in src src/etl src/elt src/analysis src/utils tests; do
  touch "$dir/__init__.py"
done

# Copiando o módulo de qualidade de dados
cat > src/utils/data_quality.py <<EOF
"""
Módulo de Qualidade de Dados para Pipeline ETL ITBI Recife
Autor: Pipeline ETL ITBI
Uso: Validação e análise de qualidade dos dados ITBI
"""

import pandas as pd
import numpy as np
from typing import Dict, List, Tuple, Any
import logging

class DataQualityAnalyzer:
    """Classe para análise de qualidade de dados do ITBI"""
    
    def __init__(self, df: pd.DataFrame):
        self.df = df
        self.quality_report = {}
        
    def analyze_missing_values(self) -> Dict[str, Any]:
        """Analisa valores ausentes no dataset"""
        missing_data = self.df.isnull().sum()
        missing_percent = (missing_data / len(self.df)) * 100
        
        return {
            'total_missing': missing_data.sum(),
            'columns_with_missing': missing_data[missing_data > 0].to_dict(),
            'missing_percentages': missing_percent[missing_percent > 0].to_dict()
        }
    
    def analyze_duplicates(self) -> Dict[str, Any]:
        """Analisa registros duplicados"""
        total_duplicates = self.df.duplicated().sum()
        duplicate_rows = self.df[self.df.duplicated()]
        
        return {
            'total_duplicates': int(total_duplicates),
            'duplicate_percentage': (total_duplicates / len(self.df)) * 100,
            'duplicate_rows': duplicate_rows.index.tolist()
        }
    
    def analyze_data_types(self) -> Dict[str, Any]:
        """Analisa tipos de dados das colunas"""
        return {
            'data_types': self.df.dtypes.astype(str).to_dict(),
            'numeric_columns': self.df.select_dtypes(include=[np.number]).columns.tolist(),
            'text_columns': self.df.select_dtypes(include=['object']).columns.tolist(),
            'datetime_columns': self.df.select_dtypes(include=['datetime']).columns.tolist()
        }
    
    def analyze_outliers(self, columns: List[str] = None) -> Dict[str, Any]:
        """Detecta outliers em colunas numéricas usando IQR"""
        if columns is None:
            columns = self.df.select_dtypes(include=[np.number]).columns
        
        outliers_info = {}
        for col in columns:
            if col in self.df.columns:
                Q1 = self.df[col].quantile(0.25)
                Q3 = self.df[col].quantile(0.75)
                IQR = Q3 - Q1
                lower_bound = Q1 - 1.5 * IQR
                upper_bound = Q3 + 1.5 * IQR
                
                outliers = self.df[(self.df[col] < lower_bound) | (self.df[col] > upper_bound)]
                
                outliers_info[col] = {
                    'count': len(outliers),
                    'percentage': (len(outliers) / len(self.df)) * 100,
                    'lower_bound': lower_bound,
                    'upper_bound': upper_bound
                }
        
        return outliers_info
    
    def generate_quality_report(self) -> Dict[str, Any]:
        """Gera relatório completo de qualidade dos dados"""
        print("🔍 Gerando relatório de qualidade dos dados...")
        
        self.quality_report = {
            'dataset_info': {
                'total_rows': len(self.df),
                'total_columns': len(self.df.columns),
                'memory_usage_mb': self.df.memory_usage(deep=True).sum() / 1024**2
            },
            'missing_values': self.analyze_missing_values(),
            'duplicates': self.analyze_duplicates(),
            'data_types': self.analyze_data_types(),
            'outliers': self.analyze_outliers(['valor_avaliacao', 'area_terreno', 'area_construida'])
        }
        
        return self.quality_report
    
    def print_quality_summary(self):
        """Imprime resumo da qualidade dos dados"""
        if not self.quality_report:
            self.generate_quality_report()
        
        print("\n📊 RELATÓRIO DE QUALIDADE DOS DADOS ITBI")
        print("=" * 45)
        
        # Informações gerais
        info = self.quality_report['dataset_info']
        print(f"📈 Registros: {info['total_rows']:,}")
        print(f"📋 Colunas: {info['total_columns']}")
        print(f"💾 Memória: {info['memory_usage_mb']:.2f} MB")
        
        # Valores ausentes
        missing = self.quality_report['missing_values']
        if missing['total_missing'] > 0:
            print(f"\n🦠 Valores ausentes: {missing['total_missing']:,}")
            for col, count in missing['columns_with_missing'].items():
                percent = missing['missing_percentages'][col]
                print(f"   • {col}: {count:,} ({percent:.1f}%)")
        else:
            print("\n✅ Nenhum valor ausente encontrado")
        
        # Duplicatas
        duplicates = self.quality_report['duplicates']
        if duplicates['total_duplicates'] > 0:
            print(f"\n🔄 Duplicatas: {duplicates['total_duplicates']:,} ({duplicates['duplicate_percentage']:.1f}%)")
        else:
            print("\n✅ Nenhuma duplicata encontrada")
        
        # Outliers
        outliers = self.quality_report['outliers']
        print(f"\n📊 Outliers detectados:")
        for col, info in outliers.items():
            if info['count'] > 0:
                print(f"   • {col}: {info['count']:,} ({info['percentage']:.1f}%)")
            else:
                print(f"   • {col}: Nenhum outlier")

def validate_itbi_data(df: pd.DataFrame) -> bool:
    """Valida se o dataset ITBI possui as colunas essenciais"""
    required_columns = ['bairro', 'tipo_imovel', 'valor_avaliacao', 'data_transacao']
    missing_columns = [col for col in required_columns if col not in df.columns]
    
    if missing_columns:
        print(f"❌ Colunas essenciais ausentes: {missing_columns}")
        return False
    
    print("✅ Dataset ITBI validado com sucesso!")
    return True

# Função de conveniência para análise rápida
def quick_quality_check(df: pd.DataFrame) -> None:
    """Análise rápida de qualidade dos dados"""
    analyzer = DataQualityAnalyzer(df)
    analyzer.generate_quality_report()
    analyzer.print_quality_summary()
EOF

echo -e "\n✅ Estrutura e dependências configuradas com sucesso!"
echo "👉 Para Windows, ative o ambiente com: .venv/Scripts/activate"
echo "👉 Para Linux/Mac, ative com: source .venv/bin/activate"
