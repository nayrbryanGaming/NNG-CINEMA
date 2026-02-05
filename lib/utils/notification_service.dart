import 'package:hive/hive.dart';

class NotificationService {
  static const String _boxName = 'notifications_box';
  static List<Map<String, dynamic>>? _cachedNotifications;

  static Future<Box<dynamic>> _openBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  static Future<void> _saveToBox(List<Map<String, dynamic>> notifications) async {
    try {
      final box = await _openBox();
      // Convert DateTime to ISO string for storage
      final serialized = notifications.map((n) => {
        ...n,
        'timestamp': (n['timestamp'] as DateTime?)?.toIso8601String(),
      }).toList();
      await box.put('items', serialized);
    } catch (_) {
      // Silently fail if storage unavailable
    }
  }

  static Future<List<Map<String, dynamic>>> _loadFromBox() async {
    try {
      final box = await _openBox();
      final raw = box.get('items');
      if (raw is List) {
        return raw.map<Map<String, dynamic>>((e) {
          final map = Map<String, dynamic>.from(e as Map);
          // Convert ISO string back to DateTime
          if (map['timestamp'] is String) {
            map['timestamp'] = DateTime.tryParse(map['timestamp']);
          }
          return map;
        }).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<void> _ensureLoaded() async {
    if (_cachedNotifications == null) {
      _cachedNotifications = await _loadFromBox();
    }
  }

  static Future<void> addTicketBookedNotification() async {
    await _ensureLoaded();
    _cachedNotifications!.add({
      'title': 'Tiket Berhasil Dipesan',
      'body': 'Selamat! Tiket Anda sudah berhasil dipesan.',
      'timestamp': DateTime.now(),
    });
    await _saveToBox(_cachedNotifications!);
  }

  static Future<void> addReminderNotification(DateTime showTime, {Duration before = const Duration(hours: 1)}) async {
    await _ensureLoaded();
    final reminderTime = showTime.subtract(before);
    if (reminderTime.isAfter(DateTime.now())) {
      _cachedNotifications!.add({
        'title': 'Pengingat Film',
        'body': before.inHours == 1 ? 'Film akan mulai dalam 1 jam!' : 'Film akan mulai dalam 30 menit!',
        'timestamp': reminderTime,
      });
      await _saveToBox(_cachedNotifications!);
    }
  }

  static Future<void> addFnbOrderNotification(String orderId) async {
    await _ensureLoaded();
    _cachedNotifications!.add({
      'title': 'Pesanan F&B Berhasil',
      'body': 'Pesanan #$orderId sudah diterima. Silakan ambil di counter.',
      'timestamp': DateTime.now(),
    });
    await _saveToBox(_cachedNotifications!);
  }

  static List<Map<String, dynamic>> getNotifications() {
    // Return cached if available, empty list otherwise (async load happens elsewhere)
    final notifications = _cachedNotifications ?? [];
    return List<Map<String, dynamic>>.from(notifications)
      ..sort((a, b) {
        final aTime = a['timestamp'] as DateTime?;
        final bTime = b['timestamp'] as DateTime?;
        if (aTime == null || bTime == null) return 0;
        return bTime.compareTo(aTime);
      });
  }

  static Future<List<Map<String, dynamic>>> getNotificationsAsync() async {
    await _ensureLoaded();
    return getNotifications();
  }

  static Future<void> clear() async {
    _cachedNotifications = [];
    await _saveToBox([]);
  }

  /// Initialize notifications on app start
  static Future<void> initialize() async {
    await _ensureLoaded();
  }
}
