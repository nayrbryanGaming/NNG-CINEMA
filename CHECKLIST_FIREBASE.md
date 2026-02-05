# ✅ CHECKLIST: Connect Firebase - Ikuti Step by Step

## 🎯 LANGKAH-LANGKAH YANG HARUS DIKERJAKAN:

### ✅ SUDAH SELESAI (Dikerjakan oleh AI):

- [x] Update package name dari `com.example.bioskop_app_modern` → `com.nng_cinema`
- [x] Update `android/app/build.gradle.kts` (applicationId & namespace)
- [x] Update `android/build.gradle.kts` (tambah Google Services)
- [x] Tambah Google Services plugin
- [x] Pindahkan MainActivity ke package yang benar
- [x] Update AndroidManifest.xml
- [x] Tambah Firebase initialization di main.dart

---

### 🔴 BELUM SELESAI (Harus Anda kerjakan):

#### [ ] STEP 1: Download google-services.json
- Buka Firebase Console di browser
- Pilih project "NNG Cinema by nayrbryanGaming"
- Klik tombol "google-services.json" (ada icon download)
- Save file yang didownload

#### [ ] STEP 2: Copy File ke Project
- Buka folder: `E:\Download\bioskop_app_modern\android\app\`
- Copy file `google-services.json` yang baru didownload ke folder tersebut
- Pastikan namanya persis: `google-services.json` (lowercase semua)

#### [ ] STEP 3: Update Firebase Core
- Buka file: `pubspec.yaml`
- Cari baris: `firebase_core: ^2.27.0`
- Ganti menjadi: `firebase_core: ^3.6.0`
- Save file

#### [ ] STEP 4: Install Dependencies
Buka terminal/command prompt, jalankan:
```bash
flutter pub get
```

#### [ ] STEP 5: Clean Project
Di terminal, jalankan:
```bash
flutter clean
```

#### [ ] STEP 6: Run App
Di terminal, jalankan:
```bash
flutter run
```

#### [ ] STEP 7: Verify Connection
Lihat di logs, harus muncul:
```
I/flutter: ✅ Firebase initialized successfully
I/flutter: ✅ App initialization completed
```

---

## 🎯 QUICK COMMANDS (Copy Paste):

Buka terminal di folder project, lalu jalankan satu per satu:

```bash
# 1. Get dependencies
flutter pub get

# 2. Clean project
flutter clean

# 3. Get dependencies lagi
flutter pub get

# 4. Run app
flutter run
```

---

## 📂 LOKASI FILE PENTING:

### File yang HARUS ADA:
```
📁 android/
   📁 app/
      📄 google-services.json  ← DOWNLOAD & TARUH DI SINI!
```

### File yang sudah diupdate:
```
📁 android/
   📁 app/
      📄 build.gradle.kts      ✅ Updated
      📁 src/main/kotlin/com/nng_cinema/
         📄 MainActivity.kt    ✅ Created
   📄 build.gradle.kts         ✅ Updated
   
📁 lib/
   📄 main.dart                ✅ Updated

📄 pubspec.yaml                ⚠️ Need to update firebase_core version
```

---

## ⚠️ TROUBLESHOOTING:

### ❌ Error: "google-services.json not found"
**Solusi**: 
- Cek file ada di `android/app/google-services.json`
- Cek nama file (harus lowercase semua)
- Jalankan `flutter clean` lalu `flutter run` lagi

### ❌ Error: "Default FirebaseApp is not initialized"
**Solusi**:
- Pastikan `google-services.json` sudah di tempat yang benar
- Pastikan sudah `flutter clean` dan `flutter pub get`
- Cek di main.dart ada `Firebase.initializeApp()`

### ❌ Error: "Duplicate class" atau "Build failed"
**Solusi**:
```bash
flutter clean
cd android
./gradlew clean
cd ..
flutter pub get
flutter run
```

### ❌ App crash saat startup
**Solusi**:
- Cek package name di `google-services.json` harus `com.nng_cinema`
- Download ulang `google-services.json` dari Firebase Console
- Pastikan App ID match dengan yang di Firebase Console

---

## 🎉 SELESAI!

Kalau sudah muncul:
```
✅ Firebase initialized successfully
✅ App initialization completed
```

Berarti **Firebase sudah terconnect!** 🚀

Selamat! Sekarang Anda bisa pakai:
- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Firebase Analytics
- dll.

---

## 📞 Need Help?

Kalau masih error, share:
1. Error message lengkap
2. Screenshot error
3. File `google-services.json` sudah ada atau belum

Saya siap bantu troubleshoot! 💪

