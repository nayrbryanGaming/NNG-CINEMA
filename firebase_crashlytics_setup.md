# Firebase Crashlytics Setup (Professional Bonus)

1. **Tambahkan dependency Crashlytics di pubspec.yaml:**
   ```yaml
   dependencies:
     firebase_crashlytics: ^3.4.9
   ```

2. **Inisialisasi Crashlytics di main.dart:**
   ```dart
   import 'package:firebase_core/firebase_core.dart';
   import 'package:firebase_crashlytics/firebase_crashlytics.dart';

   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp();
     FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
     runApp(MyApp());
   }
   ```

3. **(Opsional) Laporkan error custom:**
   ```dart
   try {
     // kode yang bisa error
   } catch (e, s) {
     FirebaseCrashlytics.instance.recordError(e, s);
   }
   ```

4. **Build dan deploy aplikasi.**

5. **Cek dashboard Crashlytics di Firebase Console.**

---

Crashlytics akan otomatis menangkap crash/error aplikasi dan mengirimkan laporan ke Firebase Console. Ini sangat profesional untuk presentasi dan debugging production.

