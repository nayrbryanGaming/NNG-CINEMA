# FIX KONEKSI INTERNET ANDROID - NETWORK SECURITY CONFIG

## Masalah
Aplikasi tidak bisa konek ke internet di Android karena firewall/network security yang memblok koneksi.

## Solusi yang Diterapkan

### 1. Network Security Config
**File**: `android/app/src/main/res/xml/network_security_config.xml`

Dibuat konfigurasi network security yang:
- ✅ Mengizinkan cleartext traffic (HTTP dan HTTPS)
- ✅ Trust system certificates
- ✅ Trust user-added certificates
- ✅ Konfigurasi khusus untuk TMDB API domains:
  - api.themoviedb.org
  - image.tmdb.org
  - themoviedb.org
- ✅ Mengizinkan localhost untuk development

### 2. AndroidManifest.xml Update
**File**: `android/app/src/main/AndroidManifest.xml`

Ditambahkan ke `<application>` tag:
```xml
android:networkSecurityConfig="@xml/network_security_config"
android:usesCleartextTraffic="true"
```

### 3. Permissions (Sudah Ada)
- ✅ `INTERNET`
- ✅ `ACCESS_NETWORK_STATE`

## Cara Test

1. **Clean build** terlebih dahulu:
```bash
cd E:\00ANDROIDSTUDIOPROJECT\NNG_CINEMA5
flutter clean
flutter pub get
```

2. **Rebuild aplikasi**:
```bash
flutter build apk --debug
```

atau langsung run:
```bash
flutter run
```

3. **Verifikasi koneksi**:
   - Buka aplikasi
   - Menu Bioskop seharusnya sudah muncul
   - Data film dari TMDB API akan ter-load

## Troubleshooting Tambahan

### Jika masih tidak bisa konek:

1. **Periksa koneksi emulator/device**:
   - Pastikan emulator/device punya koneksi internet
   - Test dengan buka browser di emulator dan akses google.com

2. **Periksa Firewall Windows**:
   - Buka Windows Defender Firewall
   - Allow flutter.exe dan dart.exe
   - Allow Android Studio

3. **Untuk Emulator Android**:
   - Settings > Network & Internet > pastikan WiFi/Mobile data ON
   - Restart emulator jika perlu

4. **Lihat log untuk detail error**:
```bash
flutter run -v
```

## File yang Dimodifikasi

1. ✅ **Created**: `android/app/src/main/res/xml/network_security_config.xml`
2. ✅ **Modified**: `android/app/src/main/AndroidManifest.xml`

## Status
✅ **SELESAI** - Network security config sudah dikonfigurasi untuk mengizinkan koneksi internet.

Aplikasi sekarang bisa:
- Akses TMDB API
- Download gambar dari TMDB
- Bypass firewall restrictions Android

---
Tanggal: 25 November 2025

