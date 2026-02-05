import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:movies_app/core/resources/app_values.dart';
import 'package:movies_app/core/resources/app_routes.dart';
import 'package:movies_app/core/services/local_credential_service.dart';
import 'package:movies_app/core/services/service_locator.dart';
import 'package:movies_app/core/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
 import 'package:movies_app/core/services/local_admin_service.dart';

class MenuView extends StatelessWidget {
  const MenuView({super.key});

  // Top circular categories
  static final List<_MenuCategory> _topCategories = [
    const _MenuCategory(icon: Icons.movie_filter, label: 'Movie', routeName: AppRoutes.moviesRoute),
    const _MenuCategory(icon: Icons.theaters, label: 'Cinema', routeName: AppRoutes.cinemasRoute),
    const _MenuCategory(icon: Icons.fastfood, label: 'F&B', routeName: AppRoutes.fnbRoute),
    const _MenuCategory(icon: Icons.sports_handball, label: 'Sports Hall', routeName: AppRoutes.sportsHallRoute),
  ];

  // Grid menu items
  static final List<_MenuCategory> _gridItems = [
    const _MenuCategory(icon: Icons.storefront, label: 'Rent', routeName: AppRoutes.rentRoute),
    const _MenuCategory(icon: Icons.campaign, label: 'Promotions', routeName: AppRoutes.promotionsRoute),
    const _MenuCategory(icon: Icons.article, label: 'News', routeName: AppRoutes.newsRoute),
    const _MenuCategory(icon: Icons.apartment, label: 'Facilities', routeName: AppRoutes.facilitiesRoute),
    const _MenuCategory(icon: Icons.handshake, label: 'Partnership', routeName: AppRoutes.partnershipRoute),
    const _MenuCategory(icon: Icons.help_center, label: 'FAQ & Contact Us', routeName: AppRoutes.faqContactRoute),
    const _MenuCategory(icon: Icons.card_membership, label: 'Membership', routeName: AppRoutes.membershipRoute),
  ];

  // Social media links
  static final List<_SocialLink> _socialLinks = const [
    _SocialLink(icon: Icons.facebook, url: 'https://facebook.com'),
    _SocialLink(icon: Icons.camera_alt, url: 'https://instagram.com'),
    _SocialLink(icon: Icons.language, url: 'https://x.com'),
    _SocialLink(icon: Icons.video_library, url: 'https://youtube.com'),
    _SocialLink(icon: Icons.music_note, url: 'https://www.tiktok.com'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppPadding.p32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(context),
                const SizedBox(height: AppSize.s8),
                _buildUserProfileSection(context),
                const SizedBox(height: AppSize.s16),
                _buildTopCategories(context),
                const Divider(color: Colors.grey, height: 28, thickness: 0.4),
                _buildGridMenu(context),
                const SizedBox(height: AppPadding.p32),
                _buildSocialSection(context),
              ],
            ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.p16, vertical: AppPadding.p12),
      child: Row(
        children: [
          Image.asset('assets/images/nng.png', height: 36),
          const SizedBox(width: AppSize.s16),
          Expanded(
            child: GestureDetector(
              onTap: () => context.goNamed(AppRoutes.searchRoute),
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey[800]!),
                ),
                padding: const EdgeInsets.symmetric(horizontal: AppPadding.p16),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: Colors.white70, size: 20),
                    SizedBox(width: 8),
                    Text('Search', style: TextStyle(color: Colors.white38)),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
            onPressed: () => context.goNamed(AppRoutes.profileRoute),
          ),
          // Admin quick access (navigates to dedicated admin login page)
          IconButton(
            icon: const Icon(Icons.admin_panel_settings, color: Colors.amber),
            tooltip: 'Admin Login',
            onPressed: () => context.goNamed(AppRoutes.adminSignInRoute),
          ),
           Stack(
             children: [
               IconButton(
                 icon: const Icon(Icons.notifications_none, color: Colors.white),
                 onPressed: () { context.goNamed(AppRoutes.notificationsRoute); },
               ),
               Positioned(
                 right: 6,
                 top: 6,
                 child: Container(
                   padding: const EdgeInsets.all(3),
                   decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                   child: const Text('3', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                 ),
               )
             ],
           ),
        ],
      ),
    );
  }

  Widget _buildUserProfileSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppPadding.p16),
      padding: const EdgeInsets.all(AppPadding.p16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Level
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppPadding.p8),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LEVEL',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      'CLASSIC',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[700],
          ),
          // Points
          Expanded(
            child: Row(
              children: [
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(AppPadding.p8),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.monetization_on,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'POINTS',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '0',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[700],
          ),
          // BluAccount
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'BLUACCOUNT',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 9,
                    ),
                  ),
                  Text(
                    'Not Linked',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCategories(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.p12),
      child: Row(
        children: _topCategories.map((c) => _CategoryCircle(category: c)).toList(),
      ),
    );
  }

  Widget _buildGridMenu(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.p16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _gridItems.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 3.8,
        ),
        itemBuilder: (ctx, i) => _MenuTile(category: _gridItems[i]),
      ),
    );
  }

  Widget _buildSocialSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('FOLLOW US', style: TextStyle(color: Colors.grey, fontSize: 13, letterSpacing: 0.5)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 14,
            runSpacing: 10,
            children: _socialLinks.map((s) => _SocialIcon(link: s)).toList(),
          ),
        ],
      ),
    );
  }
}

class _CategoryCircle extends StatelessWidget {
  final _MenuCategory category;
  const _CategoryCircle({required this.category});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(40),
            onTap: () => context.goNamed(category.routeName),
            child: Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 6, offset: const Offset(0, 3)),
                ],
              ),
              child: Icon(category.icon, color: Colors.white, size: 28),
            ),
          ),
          const SizedBox(height: 6),
            SizedBox(
              width: 70,
              child: Text(
                category.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final _MenuCategory category;
  const _MenuTile({required this.category});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.goNamed(category.routeName),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[800]!),
        ),
        child: Row(
          children: [
            Icon(category.icon, color: Colors.white70, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                category.label,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white54, size: 20),
          ],
        ),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final _SocialLink link;
  const _SocialIcon({required this.link});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(link.url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.grey[850],
        child: Icon(link.icon, color: Colors.white, size: 24),
      ),
    );
  }
}

class _MenuCategory {
  final IconData icon;
  final String label;
  final String routeName;
  const _MenuCategory({required this.icon, required this.label, required this.routeName});
}

class _SocialLink {
  final IconData icon;
  final String url;
  const _SocialLink({required this.icon, required this.url});
}

// Helper dialog and auth logic for admin quick-login
Future<void> _showAdminLoginDialog(BuildContext context) async {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _remember = false;

  await showDialog<void>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(builder: (ctx, setState) {
        bool loading = false;
        return AlertDialog(
          title: const Text('Admin Login'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FutureBuilder<Map<String, String>?>(
                future: sl<LocalCredentialService>().readAdminCredentials(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.done && snap.data != null) {
                    final creds = snap.data!;
                    _identifierController.text = creds['username'] ?? '';
                    _passwordController.text = creds['password'] ?? '';
                    _remember = true;
                  }
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _identifierController,
                        decoration: const InputDecoration(labelText: 'Username or Email'),
                      ),
                      TextField(
                        controller: _passwordController,
                        decoration: const InputDecoration(labelText: 'Password'),
                        obscureText: true,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () { Navigator.of(ctx).pop(); }, child: const Text('Cancel')),
            StatefulBuilder(
              builder: (context, innerSetState) {
                return TextButton(
                  onPressed: () async {
                    innerSetState(() => loading = true);
                    // declare variables here so catch block can reference them
                    final auth = sl<AuthService>();
                    String identifier = _identifierController.text.trim();
                    String emailToUse = identifier;
                    try {
                      if (!identifier.contains('@')) {
                        if (identifier.toLowerCase() == 'nayrbryangaming') {
                          emailToUse = 'nayrbryangaming@gmail.com';
                        } else {
                          // try resolve from Firestore users collection
                          try {
                            final q = await FirebaseFirestore.instance.collection('users').where('usernameLower', isEqualTo: identifier.toLowerCase()).limit(1).get();
                            if (q.docs.isNotEmpty) {
                              emailToUse = (q.docs.first.data()['email'] as String?) ?? identifier;
                            }
                          } catch (_) {
                            // ignore, fallback to identifier
                          }
                        }
                      }

                      await auth.signInWithEmail(emailToUse, _passwordController.text);
                    } on FirebaseAuthException catch (e) {
                      // If user not found and credentials match the designated admin, create account automatically
                      const allowedAdminEmail = 'nayrbryangaming@gmail.com';
                      const allowedAdminPassword = 'nayrbryangaming';
                      final providedPwd = _passwordController.text;
                      if (e.code == 'user-not-found' && (emailToUse == allowedAdminEmail || identifier.toLowerCase() == 'nayrbryangaming') && providedPwd == allowedAdminPassword) {
                        try {
                          await auth.signUpWithEmail(allowedAdminEmail, allowedAdminPassword);
                          // sign in newly created
                          await auth.signInWithEmail(allowedAdminEmail, allowedAdminPassword);
                        } catch (signupErr) {
                          innerSetState(() => loading = false);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal membuat akun admin: ${signupErr.toString()}')));
                          return;
                        }
                      } else {
                        innerSetState(() => loading = false);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Auth failed: ${e.message ?? e.code}')));
                        return;
                      }
                    } catch (e) {
                      innerSetState(() => loading = false);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login error: ${e.toString()}')));
                      return;
                    }

                    // provision Firestore doc if missing
                    try {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);
                        final doc = await ref.get();
                        if (!doc.exists) {
                          await ref.set({
                            'role': 'admin',
                            'username': 'nayrbryangaming',
                            'usernameLower': 'nayrbryangaming',
                            'email': emailToUse,
                            'createdAt': FieldValue.serverTimestamp(),
                          });
                        }
                      }
                    } catch (_) {}

                    // mark local admin session for device-only admin access
                    try {
                      await sl<LocalAdminService>().setAdminLoggedIn(emailToUse);
                    } catch (_) {}

                    // save local creds if requested
                    if (_remember) {
                      try {
                        await sl<LocalCredentialService>().saveAdminCredentials(emailToUse, _passwordController.text);
                      } catch (_) {}
                    }

                    if (!Navigator.of(ctx).mounted) return;
                    Navigator.of(ctx).pop();
                    GoRouter.of(context).go('/admin');
                  },
                  child: loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator()) : const Text('Login'),
                );
              },
            ),
          ],
        );
      });
    },
  );
}
