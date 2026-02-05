import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class LocalAdminService {
  static const _boxName = 'local_admin_session';
  static const _keyLogged = 'admin_logged';
  static const _keyEmail = 'admin_email';

  Box? _box;

  Future<Box> _getBox() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox(_boxName);
    }
    return _box!;
  }

  Future<void> setAdminLoggedIn(String email) async {
    try {
      final box = await _getBox();
      await box.put(_keyLogged, true);
      await box.put(_keyEmail, email);
      if (kDebugMode) print('✅ LocalAdminService: Admin session set for $email');
    } catch (e) {
      if (kDebugMode) print('❌ LocalAdminService.setAdminLoggedIn error: $e');
    }
  }

  Future<void> clearAdminSession() async {
    try {
      final box = await _getBox();
      await box.put(_keyLogged, false);
      await box.delete(_keyEmail);
      if (kDebugMode) print('✅ LocalAdminService: Admin session cleared');
    } catch (e) {
      if (kDebugMode) print('❌ LocalAdminService.clearAdminSession error: $e');
    }
  }

  Future<bool> isAdminLoggedIn() async {
    try {
      final box = await _getBox();
      final val = box.get(_keyLogged) as bool?;
      if (kDebugMode) print('🔍 LocalAdminService.isAdminLoggedIn: $val');
      return val == true;
    } catch (e) {
      if (kDebugMode) print('❌ LocalAdminService.isAdminLoggedIn error: $e');
    }
    return false;
  }

  Future<String?> adminEmail() async {
    try {
      final box = await _getBox();
      final val = box.get(_keyEmail) as String?;
      return val;
    } catch (e) {
      if (kDebugMode) print('❌ LocalAdminService.adminEmail error: $e');
    }
    return null;
  }
}

