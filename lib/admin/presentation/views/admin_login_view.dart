import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:movies_app/core/services/service_locator.dart';
import 'package:movies_app/core/services/auth_service.dart';
import 'package:movies_app/core/services/local_credential_service.dart';
import 'package:movies_app/core/services/local_admin_service.dart';
import 'package:go_router/go_router.dart';

class AdminLoginView extends StatefulWidget {
  const AdminLoginView({super.key});

  @override
  State<AdminLoginView> createState() => _AdminLoginViewState();
}

class _AdminLoginViewState extends State<AdminLoginView> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _remember = false;

  AuthService get _auth => sl<AuthService>();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      try {
        final creds = await sl<LocalCredentialService>().readAdminCredentials();
        if (creds != null) {
          _identifierController.text = creds['username'] ?? '';
          _passwordController.text = creds['password'] ?? '';
          setState(() => _remember = true);
        }
      } catch (_) {}
    });
  }

  Future<void> _showMessage(String msg) async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;
    final emailToUse = identifier.contains('@') ? identifier : (identifier.toLowerCase() == 'nayrbryangaming' ? 'nayrbryangaming@gmail.com' : identifier);

    bool authSuccess = false;

    try {
      await _auth.signInWithEmail(emailToUse, password);
      authSuccess = true;
    } catch (e) {
      // Fallback: if matches designated admin creds, try to provision or set local session
      const adminEmail = 'nayrbryangaming@gmail.com';
      const adminPwd = 'nayrbryangaming';
      if ((identifier.toLowerCase() == 'nayrbryangaming' || identifier.toLowerCase() == adminEmail) && password == adminPwd) {
        try {
          await _auth.signUpWithEmail(adminEmail, adminPwd);
          await _auth.signInWithEmail(adminEmail, adminPwd);
          authSuccess = true;
        } catch (_) {
          // Even if Firebase auth fails, allow local admin session
          authSuccess = true;
        }
      } else {
        await _showMessage('Login failed: ${e.toString()}');
        setState(() => _loading = false);
        return;
      }
    }

    if (!authSuccess) {
      setState(() => _loading = false);
      return;
    }

    if (_remember) {
      try { await sl<LocalCredentialService>().saveAdminCredentials(emailToUse, password); } catch (_) {}
    }

    // IMPORTANT: Set admin session and VERIFY it's saved
    final adminService = sl<LocalAdminService>();
    await adminService.setAdminLoggedIn(emailToUse);

    // Verify the session was saved
    final isAdminNow = await adminService.isAdminLoggedIn();
    debugPrint('Admin session saved: $isAdminNow');

    if (!isAdminNow) {
      await _showMessage('Failed to create admin session');
      setState(() => _loading = false);
      return;
    }

    if (!mounted) return;
    setState(() => _loading = false);

    // Small delay to ensure state is propagated
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    // Navigate to admin dashboard
    debugPrint('Navigating to /admin...');
    context.go('/admin');
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final darkBlue = const Color(0xFF0B3D91);
    return Scaffold(
      backgroundColor: darkBlue,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Text('Admin Sign In', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: darkBlue, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(height: 16),
                      const Text('Enter your admin credentials', style: TextStyle(color: Colors.black54), textAlign: TextAlign.center),
                      const SizedBox(height: 20),

                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _identifierController,
                              decoration: InputDecoration(labelText: 'Username or Email', prefixIcon: const Icon(Icons.person)),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock)),
                              obscureText: true,
                              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Checkbox(value: _remember, onChanged: (v) => setState(() => _remember = v ?? false)),
                                const Expanded(child: Text('Remember admin on this device', style: TextStyle(fontSize: 13))),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: darkBlue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: _loading ? null : _login,
                                child: _loading
                                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => context.goNamed('signIn'),
                        child: const Text('Back to User Login', style: TextStyle(color: Colors.black54)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
