# 🎨 PANDUAN MENGGANTI APP ICON (LAUNCHER) - NNG LOGO

## ✅ SUDAH SELESAI (Otomatis):

1. ✅ **Splash Screen Logo** - `lib/main.dart`
   - Icon material diganti dengan `Image.asset('assets/images/nng.png')`
   - Size: 120x120

2. ✅ **Error Screen Logo** - `lib/core/presentation/components/error_screen.dart`
   - `icon.png` diganti dengan `nng.png`

3. ✅ **Assets Registration** - `pubspec.yaml`
   - `assets/images/nng.png` ditambahkan

---

## 🔧 YANG PERLU DILAKUKAN MANUAL:

### **Android App Icon (Launcher Icon)**

Android membutuhkan berbagai ukuran icon untuk berbagai densitas layar.

#### Lokasi File:
```
android/app/src/main/res/
├── mipmap-mdpi/ic_launcher.png       (48x48 px)
├── mipmap-hdpi/ic_launcher.png       (72x72 px)
├── mipmap-xhdpi/ic_launcher.png      (96x96 px)
├── mipmap-xxhdpi/ic_launcher.png     (144x144 px)
└── mipmap-xxxhdpi/ic_launcher.png    (192x192 px)
```

---

## 🎯 CARA GANTI APP ICON:

### **Metode 1: Manual (Resize sendiri)**

1. **Buka `assets/images/nng.png`** di image editor (Photoshop, GIMP, dll)

2. **Resize ke berbagai ukuran**:
   - mdpi: 48x48 px
   - hdpi: 72x72 px
   - xhdpi: 96x96 px
   - xxhdpi: 144x144 px
   - xxxhdpi: 192x192 px

3. **Save ke folder yang sesuai**:
   ```
   android/app/src/main/res/mipmap-mdpi/ic_launcher.png
   android/app/src/main/res/mipmap-hdpi/ic_launcher.png
   android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
   android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
   android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png
   ```

4. **Replace file yang lama**

---

### **Metode 2: Menggunakan flutter_launcher_icons (RECOMMENDED)**

#### Step 1: Install package
Edit `pubspec.yaml`, tambahkan di `dev_dependencies`:

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1
```

#### Step 2: Tambahkan konfigurasi di `pubspec.yaml`

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/images/nng.png"
  adaptive_icon_background: "#FFFFFF"  # Warna background untuk adaptive icon
  adaptive_icon_foreground: "assets/images/nng.png"
```

#### Step 3: Run generator

```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

#### Step 4: Rebuild app

```bash
flutter clean
flutter run
```

---

### **Metode 3: Online Generator (Tercepat)**

1. **Upload nng.png** ke: https://appicon.co/
2. **Download** hasil generate (berbagai ukuran)
3. **Extract** dan copy ke folder mipmap yang sesuai
4. **Replace** file ic_launcher.png yang ada

---

## 📱 UNTUK iOS (Kalau Perlu):

iOS juga perlu berbagai ukuran icon:

```
ios/Runner/Assets.xcassets/AppIcon.appiconset/
```

Ukuran yang dibutuhkan:
- 20x20, 29x29, 40x40, 58x58, 60x60, 76x76, 80x80, 87x87, 
- 120x120, 152x152, 167x167, 180x180, 1024x1024

**Cara tercepat**: Gunakan `flutter_launcher_icons` (Metode 2)

---

## ✅ VERIFIKASI:

Setelah mengganti icon:

1. **Uninstall app lama** dari device/emulator
2. **Run ulang**:
   ```bash
   flutter clean
   flutter run
   ```
3. **Cek icon** di launcher (home screen)
4. **Cek splash screen** saat app dibuka

---

## 🎨 SPESIFIKASI ICON YANG BAIK:

- **Format**: PNG dengan transparency
- **Shape**: Square (1:1 ratio)
- **Ukuran source**: Minimal 1024x1024 px
- **Background**: Transparent atau solid color
- **Padding**: Sisakan 10-15% padding dari edge
- **Content**: Logo harus jelas di ukuran kecil

---

## 🚨 CATATAN PENTING:

1. **Jangan hapus file `icon.png`** kalau masih ada code yang menggunakannya
2. **Test di device asli** - icon bisa terlihat berbeda di emulator
3. **Adaptive Icon (Android 8+)**: Pertimbangkan foreground & background terpisah
4. **Notification Icon**: Perlu icon terpisah (monochrome) kalau pakai notifications

---

## 🎯 RECOMMENDED: Gunakan flutter_launcher_icons

Cara paling mudah dan tidak error-prone:

```bash
# 1. Edit pubspec.yaml (tambahkan flutter_launcher_icons)
# 2. Tambahkan konfigurasi flutter_launcher_icons
# 3. Run:
flutter pub get
flutter pub run flutter_launcher_icons

# 4. Clean dan run
flutter clean
flutter run
```

**Keuntungan**:
- Otomatis generate semua ukuran
- Support adaptive icons
- Konsisten di semua densitas
- Save waktu (tidak perlu resize manual)

---

## 📊 CHECKLIST:

- [x] Logo di splash screen (main.dart) ✅
- [x] Logo di error screen ✅
- [x] Assets registered di pubspec.yaml ✅
- [ ] Android launcher icon (ic_launcher.png) ⚠️ Manual
- [ ] iOS app icon ⚠️ Manual (kalau perlu)
- [ ] Test di device/emulator

---

## 💡 TIPS:

- Logo **NNG** sebaiknya punya background atau padding yang cukup
- Kalau logo terlalu detail, simplify untuk ukuran kecil
- Test icon di berbagai background (dark/light mode)
- Perhatikan safe area untuk adaptive icons

---

**Status**: Logo dalam app ✅ SELESAI  
**Status**: Launcher icon ⚠️ PERLU DILAKUKAN MANUAL

**Rekomendasi**: Gunakan `flutter_launcher_icons` untuk generate launcher icon otomatis!

