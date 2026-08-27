#!/bin/bash

# Cores para o terminal
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo "========================================"
echo " SOCIALFLOW - ATUALIZAR GITHUB"
echo "========================================"
echo ""

cd ~/development/meu_backend

echo -e "${YELLOW}[1/4] Verificando status atual...${NC}"
echo "----------------------------------------"
git status
echo ""

echo -e "${YELLOW}[2/4] Adicionando todas as alteracoes...${NC}"
echo "----------------------------------------"
git add .
echo ""

echo -e "${YELLOW}[3/4] Criando commit...${NC}"
echo "----------------------------------------"
read -p "Digite a mensagem do commit: " commit_msg
if [ -z "$commit_msg" ]; then
    commit_msg="feat: Atualizacao do SocialFlow"
    echo "Mensagem vazia! Usando: $commit_msg"
fi
git commit -m "$commit_msg"
echo ""

echo -e "${YELLOW}[4/4] Enviando para o GitHub...${NC}"
echo "----------------------------------------"
git push -u origin main
echo ""

echo -e "${GREEN}========================================"
echo " PROCESSO CONCLUIDO COM SUCESSO!"
echo "========================================${NC}"
echo ""