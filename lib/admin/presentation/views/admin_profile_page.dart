import 'package:flutter/material.dart';
import 'package:movies_app/core/services/service_locator.dart';
import 'package:movies_app/core/services/auth_service.dart';

class AdminProfilePage extends StatelessWidget {
  const AdminProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final email = sl.isRegistered<AuthService>() ? sl<AuthService>().currentUser?.email ?? 'admin@local' : 'admin@local';
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: CircleAvatar(radius: 40, child: Text(email.substring(0,1).toUpperCase()))),
            const SizedBox(height: 12),
            Center(child: Text(email, style: const TextStyle(fontWeight: FontWeight.bold))),
            const SizedBox(height: 20),
            const ListTile(title: Text('Settings'), subtitle: Text('Manage admin settings')),
            const Divider(),
            ListTile(title: const Text('Change Password'), trailing: const Icon(Icons.chevron_right)),
            ListTile(title: const Text('App Version'), subtitle: const Text('1.0.0')),
            const Spacer(),
            Center(child: ElevatedButton.icon(onPressed: () { showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Logout'), content: const Text('Confirm logout?'), actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')), TextButton(onPressed: () { Navigator.of(context).pop(); Navigator.of(context).pop(); }, child: const Text('Logout'))])); }, icon: const Icon(Icons.logout), label: const Text('Logout')))
          ],
        ),
      ),
    );
  }
}

