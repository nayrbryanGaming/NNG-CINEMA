@echo off
echo Mengganti semua ic_launcher.png dengan nng.png...

copy /Y "assets\images\nng.png" "android\app\src\main\res\mipmap-hdpi\ic_launcher.png"
copy /Y "assets\images\nng.png" "android\app\src\main\res\mipmap-mdpi\ic_launcher.png"
copy /Y "assets\images\nng.png" "android\app\src\main\res\mipmap-xhdpi\ic_launcher.png"
copy /Y "assets\images\nng.png" "android\app\src\main\res\mipmap-xxhdpi\ic_launcher.png"
copy /Y "assets\images\nng.png" "android\app\src\main\res\mipmap-xxxhdpi\ic_launcher.png"

echo.
echo Selesai! Semua logo telah diganti dengan nng.png
echo.
echo Langkah selanjutnya:
echo 1. Jalankan: flutter clean
echo 2. Jalankan: flutter pub get
echo 3. Uninstall aplikasi dari HP Anda
echo 4. Jalankan: flutter run
echo.
pause

