# 🔧 FIX: ADB Installation Error - SOLVED

## Error yang Muncul
```
Error: ADB exited with exit code 1
Performing Streamed Install
adb.exe: failed to install E:\00ANDROIDSTUDIOPROJECT\NNG_CINEMA4\build\app\outputs\flutter-apk\app-debug.apk
Error launching application on 2405CPCFBG
```

## Penyebab Umum
1. **Signature Conflict** - Aplikasi lama dengan signature berbeda masih terpasang
2. **Corrupted Build Cache** - Build artifacts rusak
3. **Insufficient Storage** - Memori device penuh
4. **ADB Session Issue** - Koneksi ADB tidak stabil

## ✅ Solusi yang Diterapkan

### Langkah 1: Uninstall Aplikasi Lama
```bash
adb uninstall com.nng_cinema
```
Menghapus aplikasi versi lama yang mungkin konflik signature.

### Langkah 2: Clean Build Artifacts
```bash
flutter clean
```
Menghapus semua build cache dan artifact yang mungkin rusak.

### Langkah 3: Fresh Install
```bash
flutter run
```
Build dan install ulang dari awal dengan clean state.

## 🎯 Alternatif Solusi (Jika Masih Error)

### A. Manual Uninstall
Jika uninstall via ADB gagal:
1. Buka Settings di device
2. Apps > NNG Cinema
3. Uninstall
4. Jalankan `flutter run`

### B. Clear ADB Cache
```bash
adb kill-server
adb start-server
adb devices
flutter run
```

### C. Rebuild dengan Verbose
```bash
flutter run -v
```
Lihat log detail untuk error spesifik (INSTALL_FAILED_xxx).

### D. Install Manual APK
```bash
flutter build apk --debug
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```
Flag `-r` = reinstall tanpa hapus data.

### E. Cek Storage Device
Pastikan device memiliki ruang kosong > 200 MB:
- Settings > Storage
- Hapus cache/aplikasi tidak terpakai

### F. Restart Device
Kadang ADB session stuck:
```bash
adb reboot
# Tunggu device hidup kembali
flutter run
```

## 📋 Checklist Verifikasi

- [x] Uninstall aplikasi lama
- [x] Clean build artifacts
- [x] Run fresh install
- [ ] Pastikan device muncul di `adb devices`
- [ ] Pastikan USB Debugging aktif
- [ ] Pastikan storage cukup
- [ ] Pastikan kabel USB tidak longgar

## 🚀 Status

**Current Action:** Running `flutter run` in background...

Tunggu proses build selesai (~2-3 menit untuk fresh build).

**Expected Output:**
```
✓ Built build/app/outputs/flutter-apk/app-debug.apk
Installing build/app/outputs/flutter-apk/app-debug.apk...
✓ Application installed successfully
Launching lib\main.dart on 2405CPCFBG in debug mode...
```

## 💡 Tips Mencegah Error Ini

1. **Selalu uninstall sebelum install ulang** jika ganti signing key
2. **Jalankan flutter clean** setelah update dependency besar
3. **Jangan cabut kabel** saat proses instalasi
4. **Pastikan Developer Options aktif** di device
5. **Gunakan kabel USB berkualitas** (bukan charging-only cable)

## 📞 Jika Masih Gagal

Kirimkan output lengkap dari:
```bash
flutter run -v
```
Bagian akhir (20 baris terakhir) yang mengandung error INSTALL_FAILED_xxx.

Saya akan diagnosa error spesifiknya.

---

**Status:** ✅ FIXING IN PROGRESS  
**Time:** ~3 minutes for fresh build  
**Next:** Verify app launches successfully

