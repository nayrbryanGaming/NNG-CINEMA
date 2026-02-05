# PANDUAN MENGGANTI LOGO APLIKASI ANDROID

## Masalah yang Terjadi
Logo aplikasi di HP belum berubah karena Android menggunakan file `ic_launcher.png` yang ada di folder mipmap, bukan dari `assets/images/nng.png`.

## Solusi Lengkap

### Cara 1: Menggunakan Script Otomatis (RECOMMENDED)

1. **Double-click file `replace_logo.bat`** yang sudah saya buat di folder root project Anda
   - Lokasi: `E:\Download\bioskop_app_modern\replace_logo.bat`
   - Script ini akan otomatis mengganti semua file ic_launcher.png dengan nng.png

2. Setelah itu, buka Command Prompt (CMD) dan jalankan perintah berikut:
   ```cmd
   cd E:\Download\bioskop_app_modern
   flutter clean
   flutter pub get
   ```

3. **PENTING:** Uninstall aplikasi dari HP Anda terlebih dahulu
   - Buka Settings > Apps > NNG Cinema > Uninstall
   - ATAU tahan icon aplikasi, lalu drag ke "Uninstall"

4. Jalankan aplikasi lagi:
   ```cmd
   flutter run
   ```

### Cara 2: Manual Copy Paste (Jika script tidak berhasil)

Copy file `nng.png` dari `assets/images/nng.png` ke lokasi-lokasi berikut dan ganti nama menjadi `ic_launcher.png`:

1. `android/app/src/main/res/mipmap-hdpi/ic_launcher.png`
2. `android/app/src/main/res/mipmap-mdpi/ic_launcher.png`
3. `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png`
4. `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png`
5. `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`

Kemudian ikuti langkah 2-4 dari Cara 1.

## Mengapa Logo Tidak Berubah?

1. **Cache Build**: Flutter menyimpan cache build, perlu `flutter clean`
2. **Aplikasi Lama Masih Terinstall**: Android menggunakan logo dari instalasi lama
3. **File Salah**: Logo Android ada di folder `mipmap`, bukan di `assets`

## Tips Tambahan

Jika setelah langkah di atas logo masih belum berubah:

1. **Rebuild dari awal:**
   ```cmd
   flutter clean
   flutter pub get
   flutter run --release
   ```

2. **Restart HP Anda** (kadang Android perlu restart untuk refresh icon)

3. **Clear Cache Launcher:**
   - Buka Settings > Apps > Launcher (atau Home Screen app)
   - Clear Cache dan Clear Data
   - Restart HP

## Catatan Penting

- Logo harus dalam format **PNG** dengan background transparan untuk hasil terbaik
- Ukuran yang disarankan:
  - mdpi: 48x48 px
  - hdpi: 72x72 px
  - xhdpi: 96x96 px
  - xxhdpi: 144x144 px
  - xxxhdpi: 192x192 px
  
- Tapi Android akan otomatis meresize jika ukuran berbeda

## File Yang Sudah Dibuat

✅ `replace_logo.bat` - Script untuk mengganti semua logo secara otomatis

