# Script PowerShell pour nettoyer et générer les adaptateurs Hive pour Wanzo

# Afficher un message d'information
Write-Host "Nettoyage avant génération des adaptateurs Hive pour Wanzo..." -ForegroundColor Cyan

# Nettoyer le cache de Pub
Write-Host "Nettoyage du cache Pub..." -ForegroundColor Green
flutter pub cache clean

# Nettoyer les fichiers de build existants
Write-Host "Suppression des fichiers de build précédents..." -ForegroundColor Green
if (Test-Path -Path "build") {
    Remove-Item -Recurse -Force "build"
}
if (Test-Path -Path ".dart_tool\build") {
    Remove-Item -Recurse -Force ".dart_tool\build"
}

# Supprimer les adaptateurs générés précédemment
Write-Host "Suppression des adaptateurs Hive précédents..." -ForegroundColor Green
Get-ChildItem -Path "." -Filter "*.g.dart" -Recurse | Remove-Item -Force

# Nettoyer les dépendances
Write-Host "Nettoyage des dépendances..." -ForegroundColor Green
flutter clean

# Obtenir les dépendances
Write-Host "Obtention des dépendances..." -ForegroundColor Green
flutter pub get

# Exécuter le build_runner avec suppression des outputs conflictuels
Write-Host "Génération des adaptateurs Hive..." -ForegroundColor Green
flutter pub run build_runner build --delete-conflicting-outputs

Write-Host "Terminé !" -ForegroundColor Cyan
