@echo off
cd /d E:\00ANDROIDSTUDIOPROJECT\2NNG_CINEMA_by_nayrbryanGaming

echo === Checking status ===
git status --short

echo.
echo === Adding all changes ===
git add --all

echo.
echo === Committing ===
git commit -m "Clean repository: Essential files only" 2>nul || echo No new changes to commit

echo.
echo === Pushing to PUBLIC (NNG-CINEMA) ===
git push origin main

echo.
echo === Pushing to BACKUP (NNGCINEMA1.0) ===
git push backup main

echo.
echo === DONE ===
echo PUBLIC:  https://github.com/nayrbryanGaming/NNG-CINEMA
echo BACKUP:  https://github.com/nayrbryanGaming/NNGCINEMA1.0

