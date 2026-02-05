# HOT RESTART CACHE ISSUE - SOLUTION ✅

## Problem
```
lib/movies/presentation/views/movies_view.dart:101:13: Error: No named parameter with the name 'subtitle'.
```

## Root Cause
Flutter hot restart **tidak selalu mendeteksi perubahan pada class constructor parameters**. File `section_header.dart` sudah memiliki parameter `subtitle` yang benar, tetapi hot restart masih menggunakan cache lama.

## ✅ SOLUTION

### Option 1: STOP dan RUN ulang (RECOMMENDED)
1. **Stop** aplikasi yang sedang berjalan
2. **Run** ulang aplikasi dari awal
3. Jangan gunakan hot restart (`r`) atau hot reload (`R`)

### Option 2: Flutter Clean + Rebuild
```bash
cd E:\00ANDROIDSTUDIOPROJECT\NNG_CINEMA4
flutter clean
flutter pub get
flutter run
```

### Option 3: Restart IDE
Jika masih bermasalah:
1. Close Android Studio / VS Code
2. Reopen project
3. Run aplikasi

## ✅ VERIFICATION

File sudah benar:

### section_header.dart
```dart
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;  // ✅ Parameter EXISTS
  final IconData? leadingIcon;
  final Function()? onSeeAllTap;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,  // ✅ Constructor parameter EXISTS
    this.leadingIcon,
    this.onSeeAllTap,
  });
```

### movies_view.dart
```dart
SectionHeader(
  title: 'Explore Movies',
  subtitle: 'Exciting movies that will entertain you!',  // ✅ Usage CORRECT
  onSeeAllTap: () {
    context.goNamed(AppRoutes.popularMoviesRoute);
  },
),
```

## 📝 Note
**Hot Restart Limitations:**
- Hot restart (`r`) tidak selalu reload perubahan constructor
- Hot restart tidak reload perubahan dependency injection
- Hot restart tidak reload perubahan global variables

**When to use Full Restart:**
- ✅ Saat menambah/mengubah constructor parameters
- ✅ Saat menambah/mengubah dependency injection
- ✅ Saat menambah new files/classes
- ✅ Saat error persist setelah hot restart

**When Hot Restart is OK:**
- ✅ UI changes (widgets, colors, text)
- ✅ Method body changes
- ✅ Logic changes dalam existing methods

---

## 🚀 QUICK FIX STEPS

1. **STOP** aplikasi (klik tombol Stop merah di IDE)
2. **RUN** ulang (klik tombol Run hijau)
3. Tunggu build selesai
4. ✅ Error akan hilang

---

**Issue:** Hot Restart Cache  
**Solution:** Full Stop + Run  
**Status:** ✅ READY

