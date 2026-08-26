#!/bin/bash

echo "# 📚 SocialFlow - Documentação Completa do Projeto"
echo ""
echo "## 📁 Estrutura de Pastas"
echo '```'
find lib -type d -maxdepth 4 | grep -v ".dart_tool" | sort
echo '```'
echo ""

echo "## 📄 Lista de Arquivos Dart"
echo '```'
find lib -name "*.dart" -type f | grep -v "build" | sort
echo '```'
echo ""

echo "## 📦 Dependências (pubspec.yaml)"
echo '```yaml'
cat pubspec.yaml
echo '```'
echo ""

echo "## 🚀 main.dart"
echo '```dart'
cat lib/main.dart 2>/dev/null || echo "Arquivo não encontrado"
echo '```'
echo ""

echo "## 🗺️ Arquivos de Rota"
for file in $(find lib -name "*route*.dart" -o -name "*router*.dart" 2>/dev/null); do
    echo "### $file"
    echo '```dart'
    cat "$file"
    echo '```'
    echo ""
done

echo "## 📱 Módulos Existentes"
for module in $(find lib/modules -maxdepth 1 -type d 2>/dev/null | grep -v "modules$"); do
    module_name=$(basename "$module")
    echo "### Módulo: $module_name"
    echo '```'
    find "$module" -type f -name "*.dart" | head -20
    echo '```'
    echo ""
done

echo "## 🏗️ Models/Entidades"
for file in $(find lib -name "*model*.dart" -o -name "*entity*.dart" 2>/dev/null | head -10); do
    echo "### $file"
    echo '```dart'
    head -80 "$file"
    echo '```'
    echo ""
done

echo "## 🔧 Services"
for file in $(find lib -name "*service*.dart" 2>/dev/null | head -10); do
    echo "### $file"
    echo '```dart'
    head -80 "$file"
    echo '```'
    echo ""
done

echo "## 🖥️ Telas/Páginas"
for file in $(find lib -name "*page*.dart" -o -name "*screen*.dart" 2>/dev/null | head -10); do
    echo "### $file"
    echo '```dart'
    head -80 "$file"
    echo '```'
    echo ""
done

echo "## 🎨 Temas e Estilos"
for file in $(find lib -name "*theme*.dart" -o -name "*style*.dart" 2>/dev/null | head -5); do
    echo "### $file"
    echo '```dart'
    head -50 "$file"
    echo '```'
    echo ""
done

echo "## ⚙️ Configurações"
for file in $(find . -maxdepth 3 -name "*.json" -o -name "*.yaml" 2>/dev/null | grep -v "pubspec" | grep -v "build" | head -10); do
    echo "### $file"
    echo '```'
    cat "$file" 2>/dev/null | head -30
    echo '```'
    echo ""
done
