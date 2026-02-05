@echo off
echo ========================================
echo NNG-CINEMA DUAL PUSH SCRIPT
echo ========================================

E:
cd E:\00ANDROIDSTUDIOPROJECT\2NNG_CINEMA_by_nayrbryanGaming

echo.
echo Current directory:
cd

echo.
echo [STEP 1] Checking remotes...
git remote -v

echo.
echo [STEP 2] Configuring backup remote...
git remote remove backup 2>nul
git remote add backup https://github.com/nayrbryanGaming/NNGCINEMA1.0.git

echo.
echo [STEP 3] Adding all files...
git add --all

echo.
echo [STEP 4] Force adding sensitive files...
git add -f android/app/google-services.json 2>nul
git add -f assets/google-services.json 2>nul
git add -f local.properties 2>nul
git add -f lib/firebase_options.dart

echo.
echo [STEP 5] Creating commit...
git commit -m "NNG-CINEMA v1.0.0 - Complete with all API keys"

echo.
echo [STEP 6] Pushing to BACKUP (NNGCINEMA1.0)...
git push backup main --force

echo.
echo [STEP 7] Pushing to PUBLIC (NNG-CINEMA)...
git push origin main --force

echo.
echo ========================================
echo PUSH COMPLETE!
echo ========================================
echo.
echo PUBLIC:  https://github.com/nayrbryanGaming/NNG-CINEMA
echo PRIVATE: https://github.com/nayrbryanGaming/NNGCINEMA1.0
echo.
pause

