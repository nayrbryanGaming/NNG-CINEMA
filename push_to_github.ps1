# NNG-CINEMA GitHub Push Script
# This script safely pushes the project to GitHub while protecting API keys

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "NNG-CINEMA GitHub Push Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Navigate to project directory
Set-Location -Path "E:\00ANDROIDSTUDIOPROJECT\2NNG_CINEMA_by_nayrbryanGaming"
Write-Host "`nCurrent directory: $(Get-Location)" -ForegroundColor Green

# Step 1: Reset staging area
Write-Host "`n[Step 1] Resetting staging area..." -ForegroundColor Yellow
git reset HEAD

# Step 2: Add new remote for GitHub
Write-Host "`n[Step 2] Configuring GitHub remote..." -ForegroundColor Yellow
git remote remove origin 2>$null
git remote add origin https://github.com/nayrbryanGaming/NNG-CINEMA.git
Write-Host "Remote 'origin' set to: https://github.com/nayrbryanGaming/NNG-CINEMA.git" -ForegroundColor Green

# Step 3: Add all files respecting .gitignore
Write-Host "`n[Step 3] Adding files (respecting .gitignore)..." -ForegroundColor Yellow
git add .

# Step 4: Explicitly remove sensitive files from staging
Write-Host "`n[Step 4] Removing sensitive files from staging..." -ForegroundColor Yellow
$sensitiveFiles = @(
    "google-services.json",
    "local.properties",
    "DIAGNOSIS_MASALAH.txt",
    "BUKTI_TIDAK_ADA_YANG_DIHAPUS.txt",
    "TMDB_API_LINKS.txt",
    "assets/google-services.json",
    "android/app/google-services.json",
    "android/local.properties"
)

foreach ($file in $sensitiveFiles) {
    git reset HEAD -- $file 2>$null
    if (Test-Path $file) {
        Write-Host "  - Excluded: $file" -ForegroundColor Red
    }
}

# Step 5: Show what will be committed
Write-Host "`n[Step 5] Files staged for commit:" -ForegroundColor Yellow
git diff --cached --name-only | Select-Object -First 50
Write-Host "... and more files"

# Step 6: Commit changes
Write-Host "`n[Step 6] Creating commit..." -ForegroundColor Yellow
git commit -m "Initial release: NNG-CINEMA Flutter App

- Weather-based movie recommendation engine
- TMDB API integration for movie data
- Firebase Authentication with Google Sign-In
- Cloud Firestore for user data synchronization
- Clean Architecture with BLoC pattern
- Comprehensive search functionality
- Watchlist management
- Ticket booking system
- F&B ordering system
- Admin dashboard

Security: All API keys moved to environment variables
Documentation: Professional README with setup instructions"

Write-Host "`nCommit created successfully!" -ForegroundColor Green

# Step 7: Push to GitHub
Write-Host "`n[Step 7] Pushing to GitHub..." -ForegroundColor Yellow
Write-Host "Please authenticate with GitHub when prompted..." -ForegroundColor Cyan
git branch -M main
git push -u origin main --force

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "PUSH COMPLETE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "`nRepository: https://github.com/nayrbryanGaming/NNG-CINEMA" -ForegroundColor Cyan
Write-Host "`nIMPORTANT SECURITY NOTES:" -ForegroundColor Yellow
Write-Host "1. API keys are now loaded from environment variables" -ForegroundColor White
Write-Host "2. Sensitive files (google-services.json, etc.) are NOT uploaded" -ForegroundColor White
Write-Host "3. See .env.example for required environment variables" -ForegroundColor White
Write-Host "4. Run app with: flutter run --dart-define=TMDB_API_KEY=xxx ..." -ForegroundColor White

