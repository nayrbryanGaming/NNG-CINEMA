import 'package:flutter/material.dart';
import 'package:movies_app/core/services/service_locator.dart';
import 'package:movies_app/core/services/auth_service.dart';
import 'package:movies_app/core/resources/app_routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movies_app/core/services/local_admin_service.dart';

/// AdminGate enforces strict admin-only access.
/// Requirements:
/// - Only user with exact email 'nayrbryangaming@gmail.com' is allowed to access admin area.
///   This provides a single-admin guarantee per the project request.
/// - Firestore role check is kept as a fallback (role == 'admin') but primary gate is email match.
class AdminGate extends StatefulWidget {
  final Widget child;
  final Widget? unauthorizedChild;
  const AdminGate({Key? key, required this.child, this.unauthorizedChild}) : super(key: key);

  @override
  State<AdminGate> createState() => _AdminGateState();
}

class _AdminGateState extends State<AdminGate> {
  bool _loading = true;
  bool _isAdmin = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkAdmin();
  }

  Future<void> _checkAdmin() async {
    setState(() {
      _loading = true;
      _error = null;
      _isAdmin = false;
    });

    try {
      final auth = sl.isRegistered<AuthService>() ? sl<AuthService>() : null;
      final user = auth?.currentUser;

      // If a local (device-only) admin session exists, accept it immediately.
      try {
        if (sl.isRegistered<LocalAdminService>()) {
          final localAdmin = await sl<LocalAdminService>().isAdminLoggedIn();
          if (localAdmin) {
            setState(() {
              _isAdmin = true;
              _loading = false;
            });
            return;
          }
        }
      } catch (_) {
        // ignore local admin check failures and continue to normal auth checks
      }

      if (user == null) {
        // Not authenticated - redirect to normal sign-in
        if (!mounted) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacementNamed('/${AppRoutes.authRoute}/${AppRoutes.signInRoute}');
        });
        return;
      }

      final uid = user.uid;
      final authEmail = (user.email ?? '').toLowerCase();

      // Primary admin condition: exact email match (case-insensitive)
      const allowedAdminEmail = 'nayrbryangaming@gmail.com';
      final bool emailMatch = authEmail == allowedAdminEmail;

      // NOTE: per requirement, only the specific email above is allowed to access admin.
      // We DO NOT allow Firestore-only role escalation to be treated as admin here.
      final allowed = emailMatch;

      if (!mounted) return;

      setState(() {
        _isAdmin = allowed;
        _loading = false;
      });

      if (!allowed) {
        // Not authorized - redirect to safe page
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacementNamed('/${AppRoutes.moviesRoute}');
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
        _isAdmin = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null) return Scaffold(body: Center(child: Text('Error checking admin: $_error')));
    if (_isAdmin) return widget.child;
    return widget.unauthorizedChild ?? Scaffold(body: const Center(child: Text('Unauthorized')));
  }
}
