import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class LocalCredentialService {
  static const _boxName = 'local_credentials';
  static const _keyUsername = 'admin_username';
  static const _keyPassword = 'admin_password';

  Future<void> saveAdminCredentials(String usernameOrEmail, String password) async {
    try {
      final box = await Hive.openBox(_boxName);
      await box.put(_keyUsername, usernameOrEmail);
      await box.put(_keyPassword, password);
      await box.close();
    } catch (e) {
      if (kDebugMode) print('LocalCredentialService.save error: $e');
    }
  }

  Future<Map<String, String>?> readAdminCredentials() async {
    try {
      final box = await Hive.openBox(_boxName);
      final user = box.get(_keyUsername) as String?;
      final pass = box.get(_keyPassword) as String?;
      await box.close();
      if (user != null && pass != null) return {'username': user, 'password': pass};
    } catch (e) {
      if (kDebugMode) print('LocalCredentialService.read error: $e');
    }
    return null;
  }

  Future<void> clearAdminCredentials() async {
    try {
      final box = await Hive.openBox(_boxName);
      await box.delete(_keyUsername);
      await box.delete(_keyPassword);
      await box.close();
    } catch (e) {
      if (kDebugMode) print('LocalCredentialService.clear error: $e');
    }
  }
}
