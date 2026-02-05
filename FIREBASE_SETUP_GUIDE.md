# 🔥 Cara Connect ke Firebase - Panduan Lengkap

## ✅ Status Update Otomatis
Saya sudah mengupdate file-file berikut:
1. ✅ `android/app/build.gradle.kts` - Ditambahkan plugin Google Services
2. ✅ `android/build.gradle.kts` - Ditambahkan classpath Google Services
3. ✅ `android/app/src/main/AndroidManifest.xml` - Update app label
4. ✅ MainActivity dipindahkan ke package `com.nng_cinema`

---

## 📋 Langkah-Langkah yang Harus Anda Lakukan:

### 1️⃣ Download file `google-services.json` dari Firebase Console

Dari screenshot Firebase Console Anda:
1. Klik tombol **"google-services.json"** (yang ada icon download)
2. File akan terdownload ke komputer Anda

### 2️⃣ Letakkan file `google-services.json`

**PENTING**: Letakkan file yang baru didownload ke lokasi ini:
```
E:\Download\bioskop_app_modern\android\app\google-services.json
```

Struktur folder harus seperti ini:
```
android/
  app/
    google-services.json  ← Taruh di sini!
    build.gradle.kts
    src/
```

### 3️⃣ Cek Firebase SDK di `pubspec.yaml`

File `pubspec.yaml` Anda sudah ada `firebase_core: ^2.27.0`, tapi versinya lama.
Update ke versi terbaru:

```yaml
dependencies:
  firebase_core: ^3.6.0  # Update ini
```

Jalankan:
```bash
flutter pub get
```

### 4️⃣ Initialize Firebase di `main.dart`

File `main.dart` Anda sudah ada import Firebase, tapi perlu tambahkan initialization.
Cek di fungsi `_initializeApp()` di `AppInitializer`:

```dart
Future<void> _initializeApp() async {
  try {
    // Step 1: Initialize Firebase FIRST
    setState(() => _initializationStatus = 'Connecting to Firebase...');
    await Firebase.initializeApp();
    
    // Step 2: Initialize Hive
    setState(() => _initializationStatus = 'Loading database...');
    await _initializeHive();

    // Step 3: Initialize services
    setState(() => _initializationStatus = 'Setting up services...');
    await Future.microtask(() => ServiceLocator.init());

    if (kDebugMode) {
      print('✅ App initialization completed');
    }

    setState(() {
      _isInitialized = true;
      _initializationStatus = 'Ready!';
    });
  } catch (e) {
    if (kDebugMode) {
      print('❌ App initialization error: $e');
    }
    setState(() {
      _initializationStatus = 'Initialization failed: $e';
    });
  }
}
```

### 5️⃣ Clean dan Rebuild Project

Setelah semua langkah di atas, jalankan:

```bash
flutter clean
flutter pub get
flutter run
```

---

## 🔍 Cara Verifikasi Firebase Sudah Terkoneksi

### 1. Check Logs saat App Running:
```
I/flutter: ✅ Firebase initialized successfully
I/flutter: ✅ App initialization completed
```

### 2. Check di Firebase Console:
- Buka Firebase Console → Project Overview
- Lihat di bagian "Your apps" → Android app harus muncul
- Status: "Connected" atau "Active"

---

## ⚠️ Troubleshooting

### Error: "google-services.json not found"
**Solusi**: Pastikan file ada di `android/app/google-services.json`

### Error: "Default FirebaseApp is not initialized"
**Solusi**: 
1. Pastikan `await Firebase.initializeApp()` dipanggil di `main.dart`
2. Pastikan `google-services.json` ada di tempat yang benar

### Error: "The plugin firebase_core requires your minSdkVersion"
**Solusi**: Firebase membutuhkan minSdk 21+
Check di `android/app/build.gradle.kts`:
```kotlin
minSdk = 21  // atau lebih tinggi
```

### Error: "Duplicate class found"
**Solusi**: 
```bash
flutter clean
cd android
./gradlew clean
cd ..
flutter run
```

---

## 📱 Testing Firebase Connection

Setelah setup, test dengan code sederhana di `main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';

Future<void> testFirebase() async {
  try {
    await Firebase.initializeApp();
    print('✅ Firebase connected successfully!');
    print('Firebase App Name: ${Firebase.app().name}');
  } catch (e) {
    print('❌ Firebase connection failed: $e');
  }
}
```

---

## 🎯 Checklist Lengkap

- [ ] Download `google-services.json` dari Firebase Console
- [ ] Letakkan file di `android/app/google-services.json`
- [ ] Update `firebase_core` di `pubspec.yaml` ke versi terbaru
- [ ] Jalankan `flutter pub get`
- [ ] Tambahkan `Firebase.initializeApp()` di `main.dart`
- [ ] Jalankan `flutter clean`
- [ ] Jalankan `flutter run`
- [ ] Cek logs untuk "Firebase initialized successfully"

---

## 📞 Package Name Configuration

Pastikan package name konsisten di semua file:

### ✅ Sudah Diupdate (oleh saya):
- `android/app/build.gradle.kts` → `applicationId = "com.nng_cinema"`
- `android/app/build.gradle.kts` → `namespace = "com.nng_cinema"`
- `MainActivity.kt` → `package com.nng_cinema`

### 🔍 Cek Manual:
Di `google-services.json` yang Anda download, harus ada:
```json
{
  "project_info": {...},
  "client": [
    {
      "client_info": {
        "package_name": "com.nng_cinema"  ← Harus sama!
      }
    }
  ]
}
```

---

## 🚀 Next Steps Setelah Firebase Terkoneksi

Setelah Firebase berhasil terkoneksi, Anda bisa:

1. **Tambah Firebase Authentication**
   ```bash
   flutter pub add firebase_auth
   ```

2. **Tambah Cloud Firestore (Database)**
   ```bash
   flutter pub add cloud_firestore
   ```

3. **Tambah Firebase Storage**
   ```bash
   flutter pub add firebase_storage
   ```

4. **Tambah Firebase Analytics**
   ```bash
   flutter pub add firebase_analytics
   ```

---

## 💡 Tips Penting

1. **JANGAN commit `google-services.json` ke Git** (sudah ada di `.gitignore`)
2. **Backup `google-services.json`** di tempat aman
3. Jika ganti device/komputer, download ulang dari Firebase Console
4. Untuk iOS, perlu file `GoogleService-Info.plist` (terpisah)

---

## 🎉 Kesimpulan

Setelah mengikuti semua langkah di atas, aplikasi Anda akan:
- ✅ Terkoneksi ke Firebase
- ✅ Siap menggunakan Firebase services
- ✅ Package name konsisten di semua file
- ✅ Ready for production!

**Yang paling PENTING**: Download `google-services.json` dan taruh di `android/app/`!

