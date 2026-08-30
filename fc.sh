#!/bin/bash

# ============================================
# Script para limpar e executar o Flutter
# ============================================

# Define o diretório de destino dos logs
LOG_DIR="/Users/khambay/Documents/0_z/logsFlutter"

# Cria o diretório se ele não existir
mkdir -p "$LOG_DIR"

# Obtém a data e hora atual no formato YYYYMMDD_HHMMSS
DATA_HORA=$(date +"%Y%m%d_%H%M%S")

# Nome do arquivo de log com caminho completo
LOG_FILE="${LOG_DIR}/flutter_log_completo_${DATA_HORA}.txt"

echo "🚀 Iniciando limpeza e build do Flutter..."
echo "📁 Log será salvo em: $LOG_FILE"
echo ""

# 1. Limpa o cache do Flutter
echo "🧹 1. Executando flutter clean..."
flutter clean

# 2. Remove o .dart_tool manualmente
echo "🗑️  2. Removendo .dart_tool..."
rm -rf .dart_tool

# 3. Remove a pasta build
echo "🗑️  3. Removendo build..."
rm -rf build

# 4. Recupera as dependências
echo "📦 4. Executando flutter pub get..."
flutter pub get

# 5. Executa o app com verbose e salva o log
echo "🚀 5. Executando flutter run -d chrome --verbose..."
echo "📝 Salvando log em: $LOG_FILE"
echo ""
echo "--------------------------------------------------"
echo "🔴 O aplicativo está rodando. Pressione Ctrl+C para parar."
echo "--------------------------------------------------"
echo ""

flutter run -d chrome --verbose 2>&1 | tee "$LOG_FILE"

# Mensagem final (quando o usuário pressionar Ctrl+C)
echo ""
echo "--------------------------------------------------"
echo "✅ Execução finalizada."
echo "📁 Log salvo em: $LOG_FILE"
echo "--------------------------------------------------"