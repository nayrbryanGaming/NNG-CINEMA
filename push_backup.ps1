# NNG-CINEMA BACKUP Push Script
# Push ALL files including sensitive data to PRIVATE backup repo

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "NNG-CINEMA BACKUP Push Script" -ForegroundColor Cyan
Write-Host "Pushing to PRIVATE BACKUP repo (NNGCINEMA1.0)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Navigate to project directory
Set-Location -Path "E:\00ANDROIDSTUDIOPROJECT\2NNG_CINEMA_by_nayrbryanGaming"
Write-Host "`nCurrent directory: $(Get-Location)" -ForegroundColor Green

# Step 1: Configure backup remote
Write-Host "`n[Step 1] Configuring backup remote..." -ForegroundColor Yellow
git remote remove backup 2>$null
git remote add backup https://github.com/nayrbryanGaming/NNGCINEMA1.0.git
Write-Host "Remote 'backup' set to: https://github.com/nayrbryanGaming/NNGCINEMA1.0.git" -ForegroundColor Green

# Step 2: Create a temporary branch for backup with ALL files
Write-Host "`n[Step 2] Creating backup commit with ALL files..." -ForegroundColor Yellow

# Force add all files including those in .gitignore
git add --force .
git add --force google-services.json 2>$null
git add --force android/app/google-services.json 2>$null
git add --force assets/google-services.json 2>$null
git add --force local.properties 2>$null
git add --force android/local.properties 2>$null
git add --force DIAGNOSIS_MASALAH.txt 2>$null
git add --force BUKTI_TIDAK_ADA_YANG_DIHAPUS.txt 2>$null
git add --force TMDB_API_LINKS.txt 2>$null
git add --force lib/firebase_options.dart 2>$null

# Step 3: Commit
Write-Host "`n[Step 3] Creating backup commit..." -ForegroundColor Yellow
git commit -m "FULL BACKUP: NNG-CINEMA with ALL sensitive files

BACKUP INCLUDES:
- All API keys (TMDB, Firebase, Weather)
- google-services.json
- local.properties
- Firebase options with hardcoded keys
- All documentation files with API references

WARNING: This is a PRIVATE backup repository
DO NOT make this repository public

Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

# Step 4: Push to backup
Write-Host "`n[Step 4] Pushing to BACKUP repository..." -ForegroundColor Yellow
git push backup main --force

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "BACKUP PUSH COMPLETE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "`nBackup Repository: https://github.com/nayrbryanGaming/NNGCINEMA1.0" -ForegroundColor Cyan
Write-Host "`nThis backup contains ALL sensitive data!" -ForegroundColor Red
Write-Host "Keep this repository PRIVATE!" -ForegroundColor Red

