import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/notification_service.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final all = await NotificationService.getNotificationsAsync();
    final filtered = all.where(_isBookingOrReminder).toList();
    if (mounted) {
      setState(() {
        _notifications = filtered;
        _isLoading = false;
      });
    }
  }

  bool _isBookingOrReminder(Map<String, dynamic> n) {
    final title = (n['title'] ?? '').toString().toLowerCase();
    // Hanya notifikasi booking tiket dan reminder tiket
    return title.contains('tiket berhasil dipesan') ||
        title.contains('pengingat film') ||
        title.contains('reminder tiket') ||
        title.contains('booking confirmation') ||
        title.contains('pesanan f&b');
  }

  void _goBack(BuildContext context) {
    // Use GoRouter to navigate back to home instead of pop
    // This prevents black screen when notifications is accessed as a main route
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/movies');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF141414),
        appBar: AppBar(
          title: const Text('Notifications'),
          backgroundColor: const Color(0xFF141414),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _goBack(context),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF141414),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _goBack(context),
        ),
        actions: [
          if (_notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Clear all',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Hapus semua notifikasi?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Batal')),
                      TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Hapus')),
                    ],
                  ),
                );
                if (confirm == true) {
                  await NotificationService.clear();
                  _loadNotifications();
                }
              },
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? const Center(child: Text('Belum ada notifikasi tiket.', style: TextStyle(color: Colors.white70)))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (c, i) {
                final n = _notifications[i];
                final dt = n['timestamp'] is DateTime ? n['timestamp'] as DateTime : null;
                return ListTile(
                  tileColor: const Color(0xFF111111),
                  title: Text(n['title'] ?? '-', style: const TextStyle(color: Colors.white)),
                  subtitle: Text(n['body'] ?? '', style: const TextStyle(color: Colors.white70)),
                  trailing: dt != null
                      ? Text(
                          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(color: Colors.white38),
                        )
                      : null,
                  onTap: () {
                    // Semua notifikasi hanya menampilkan dialog detail, tidak navigasi ke halaman lain
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(n['title'] ?? '-'),
                        content: Text(n['body'] ?? ''),
                        actions: [TextButton(onPressed: () => Navigator.of(_).pop(), child: const Text('Close'))],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
