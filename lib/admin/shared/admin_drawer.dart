import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movies_app/core/services/service_locator.dart';
import 'package:movies_app/core/services/auth_service.dart';
import 'package:movies_app/core/services/local_admin_service.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1a1a2e),
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade900, Colors.purple.shade900],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Icon(Icons.admin_panel_settings, color: Colors.white, size: 40),
                SizedBox(height: 8),
                Text('Admin Panel', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                Text('NNG Cinema', style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          _buildMenuItem(context, Icons.dashboard, 'Dashboard', '/admin'),
          _buildMenuItem(context, Icons.analytics, 'Analytics', '/admin/analytics'),
          _buildMenuItem(context, Icons.movie, 'Movies', '/admin/movies'),
          _buildMenuItem(context, Icons.theaters, 'Cinemas', '/admin/cinemas'),
          _buildMenuItem(context, Icons.schedule, 'Schedules', '/admin/schedules'),
          _buildMenuItem(context, Icons.shopping_cart, 'Orders', '/admin/orders'),
          _buildMenuItem(context, Icons.people, 'Users', '/admin/users'),
          _buildMenuItem(context, Icons.history, 'Audit Log', '/admin/audit'),
          const Divider(color: Colors.white24),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
            onTap: () async {
              Navigator.of(context).pop();
              await Future.delayed(const Duration(milliseconds: 200));
              try {
                await sl<AuthService>().signOut();
              } catch (_) {}
              try {
                await sl<LocalAdminService>().clearAdminSession();
              } catch (_) {}
              context.go('/auth/signIn');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, String route) {
    final isSelected = GoRouterState.of(context).uri.path == route;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.blue : Colors.white70),
      title: Text(title, style: TextStyle(color: isSelected ? Colors.blue : Colors.white)),
      selected: isSelected,
      selectedTileColor: Colors.blue.withOpacity(0.1),
      onTap: () {
        Navigator.of(context).pop();
        context.go(route);
      },
    );
  }
}
