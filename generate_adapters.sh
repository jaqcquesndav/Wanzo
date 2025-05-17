#!/bin/bash

# Script pour nettoyer et générer les adaptateurs Hive pour Wanzo

# Afficher un message d'information
echo "Nettoyage avant génération des adaptateurs Hive pour Wanzo..."

# Nettoyer le cache de Pub
echo "Nettoyage du cache Pub..."
flutter pub cache clean

# Nettoyer les fichiers de build existants
echo "Suppression des fichiers de build précédents..."
rm -rf build/
rm -rf .dart_tool/build/

# Supprimer les adaptateurs générés précédemment
echo "Suppression des adaptateurs Hive précédents..."
find . -name "*.g.dart" -type f -delete

# Nettoyer les dépendances
echo "Nettoyage des dépendances..."
flutter clean

# Obtenir les dépendances
echo "Obtention des dépendances..."
flutter pub get

# Exécuter le build_runner avec suppression des outputs conflictuels
echo "Génération des adaptateurs Hive..."
flutter pub run build_runner build --delete-conflicting-outputs

echo "Terminé !"
