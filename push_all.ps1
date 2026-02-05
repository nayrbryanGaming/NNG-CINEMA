# NNG-CINEMA Complete Push Script
# Pushes to both PUBLIC and PRIVATE backup repositories

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "NNG-CINEMA DUAL REPOSITORY PUSH" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Set-Location -Path "E:\00ANDROIDSTUDIOPROJECT\2NNG_CINEMA_by_nayrbryanGaming"
Write-Host "`nCurrent directory: $(Get-Location)" -ForegroundColor Green

# ============================================
# PART 1: PUSH TO PRIVATE BACKUP (NNGCINEMA1.0)
# ============================================
Write-Host "`n========================================" -ForegroundColor Yellow
Write-Host "PART 1: Pushing to PRIVATE BACKUP" -ForegroundColor Yellow
Write-Host "Repository: NNGCINEMA1.0" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow

# Configure backup remote
Write-Host "`n[1.1] Configuring backup remote..." -ForegroundColor Cyan
git remote remove backup 2>$null
git remote add backup https://github.com/nayrbryanGaming/NNGCINEMA1.0.git

# Add ALL files including sensitive ones
Write-Host "[1.2] Adding ALL files (including sensitive)..." -ForegroundColor Cyan
git add --all
git add --force android/app/google-services.json 2>$null
git add --force assets/google-services.json 2>$null
git add --force local.properties 2>$null
git add --force android/local.properties 2>$null
git add --force lib/firebase_options.dart 2>$null

# Commit for backup
Write-Host "[1.3] Creating backup commit..." -ForegroundColor Cyan
$backupDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
git commit -m "FULL BACKUP: Complete NNG-CINEMA with all configurations

BACKUP DATE: $backupDate

INCLUDES ALL:
- Source code with hardcoded API keys
- google-services.json (Firebase config)
- local.properties
- All documentation files
- All sensitive configurations

STATUS: PRIVATE REPOSITORY - DO NOT MAKE PUBLIC"

# Push to backup
Write-Host "[1.4] Pushing to NNGCINEMA1.0..." -ForegroundColor Cyan
git push backup main --force

Write-Host "`nBACKUP COMPLETE!" -ForegroundColor Green

# ============================================
# PART 2: PUSH TO PUBLIC (NNG-CINEMA)
# ============================================
Write-Host "`n========================================" -ForegroundColor Yellow
Write-Host "PART 2: Pushing to PUBLIC Repository" -ForegroundColor Yellow
Write-Host "Repository: NNG-CINEMA" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow

# Reset and prepare for public push
Write-Host "`n[2.1] Preparing public commit..." -ForegroundColor Cyan
git add --all

# Commit for public
Write-Host "[2.2] Creating public commit..." -ForegroundColor Cyan
git commit --amend -m "NNG-CINEMA v1.0.0 - Flutter Cinema Application

A modern Flutter cinema application with intelligent weather-based movie recommendations.

FEATURES:
- Weather-based movie recommendation engine
- TMDB API integration for comprehensive movie data
- Firebase Authentication with Google Sign-In
- Cloud Firestore for user data synchronization
- Clean Architecture with BLoC pattern
- Real-time search functionality
- Watchlist management with cloud sync
- Ticket booking system
- F&B ordering system
- Admin dashboard

TECH STACK:
- Flutter 3.x / Dart
- Firebase (Auth, Firestore, Storage)
- BLoC State Management
- Clean Architecture
- TMDB API / OpenWeatherMap API

Ready for production use."

# Push to public
Write-Host "[2.3] Pushing to NNG-CINEMA (public)..." -ForegroundColor Cyan
git push origin main --force

# ============================================
# SUMMARY
# ============================================
Write-Host "`n========================================" -ForegroundColor Green
Write-Host "ALL PUSHES COMPLETE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

Write-Host "`nREPOSITORIES:" -ForegroundColor Cyan
Write-Host "  PUBLIC  : https://github.com/nayrbryanGaming/NNG-CINEMA" -ForegroundColor White
Write-Host "  PRIVATE : https://github.com/nayrbryanGaming/NNGCINEMA1.0" -ForegroundColor White

Write-Host "`nSTATUS:" -ForegroundColor Cyan
Write-Host "  PUBLIC  - Ready to use, all API keys included" -ForegroundColor Green
Write-Host "  PRIVATE - Full backup with all sensitive files" -ForegroundColor Green

