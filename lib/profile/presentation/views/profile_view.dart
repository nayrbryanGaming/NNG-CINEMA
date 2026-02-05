import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movies_app/core/presentation/components/loading_indicator.dart';
import 'package:movies_app/core/presentation/components/shimmer_image.dart';
import 'package:movies_app/core/resources/app_routes.dart';
import 'package:movies_app/core/services/service_locator.dart';
import 'package:movies_app/core/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:movies_app/core/presentation/utils/color_utils.dart';
import 'package:movies_app/profile/data/datasource/profile_service.dart';
import 'package:movies_app/profile/domain/entities/user_profile.dart';
import 'package:movies_app/profile/presentation/views/movie_diary_view.dart';
import 'package:movies_app/profile/presentation/views/event_view.dart';
import 'package:movies_app/profile/presentation/views/faq_contact_view.dart';
import 'package:movies_app/profile/data/reward_service.dart';
import 'package:movies_app/profile/presentation/views/rewards_view.dart';
import 'package:movies_app/profile/presentation/views/member_card_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late Future<UserProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    _refreshProfile();
  }

  void _refreshProfile() {
    setState(() {
      _profileFuture = sl<ProfileService>().getProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: Colors.white),
          ),
          IconButton(
            onPressed: () {
              context.goNamed(AppRoutes.notificationsRoute);
            },
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          ),
          IconButton(
            onPressed: _confirmSignOut,
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      body: FutureBuilder<UserProfile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text(
                'Failed to load profile.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final profile = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header Section
                _buildProfileHeader(context, profile),

                const SizedBox(height: 24),

                // Membership Card Section
                _buildMembershipCard(context, profile),

                const SizedBox(height: 24),

                // Transaction History
                _buildTransactionHistory(context),

                const SizedBox(height: 24),

                // Rewards Section
                _buildRewardsSection(context, profile),

                const SizedBox(height: 24),

                // My Features Section
                _buildMyFeaturesSection(context),

                const SizedBox(height: 24),

                // Other Section
                _buildOtherSection(context),

                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserProfile profile) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Profile Picture
          GestureDetector(
            onTap: () async {
              final result = await context.pushNamed(AppRoutes.editProfileRoute, extra: profile);
              if (result == true) {
                _refreshProfile();
              }
            },
            child: Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: withOpacityColor(Colors.white, 0.2), width: 2),
                  ),
                  child: ClipOval(
                    child: ShimmerImage(
                      imageUrl: profile.profilePictureUrl,
                      width: 80,
                      height: 80,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Profile Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.verified,
                      color: Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        profile.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.badge_outlined,
                      color: withOpacityColor(Colors.white, 0.6),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      profile.userId,
                      style: TextStyle(
                        color: withOpacityColor(Colors.white, 0.6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      color: withOpacityColor(Colors.white, 0.6),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '@${profile.username}',
                      style: TextStyle(
                        color: withOpacityColor(Colors.white, 0.6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembershipCard(BuildContext context, UserProfile profile) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE53935),
            Color(0xFFD32F2F),
            Color(0xFFC62828),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: withOpacityColor(Colors.red, 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Opacity(
                opacity: 0.1,
                child: Image.asset(
                  'assets/images/nng.png', // ganti dengan asset lokal yang sudah ada
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.star_rounded,
                            color: Colors.red,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'NNG Classic',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MemberCardView(profile: profile),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.qr_code, size: 18),
                            SizedBox(width: 4),
                            Text(
                              'QR',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  profile.name.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  profile.userId.replaceAllMapped(
                    RegExp(r'.{4}'),
                    (match) => '${match.group(0)} ',
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RewardsView(profile: profile),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: withOpacityColor(Colors.black, 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'EXPLORE BENEFIT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionHistory(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: withOpacityColor(Colors.red, 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.receipt_long_rounded,
            color: Colors.red,
            size: 24,
          ),
        ),
        title: const Text(
          'Transaction History',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'View your movie/F&B order history',
          style: TextStyle(
            color: withOpacityColor(Colors.white, 0.6),
            fontSize: 13,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: withOpacityColor(Colors.white, 0.4),
        ),
        onTap: () {
          context.pushNamed(AppRoutes.myTicketsRoute);
        },
      ),
    );
  }

  Widget _buildRewardsSection(BuildContext context, UserProfile profile) {
    final rewardService = sl<RewardService>();
    return FutureBuilder(
      future: rewardService.load(profile).then((_) => rewardService.seedDefaults(profile)),
      builder: (ctx, snapshot) {
        final points = rewardService.points;
        final couponsCount = profile.coupons.length;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'REWARDS',
                style: TextStyle(
                  color: withOpacityColor(Colors.white, 0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: withOpacityColor(Colors.purple, 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.card_giftcard_rounded,
                        color: Colors.purple,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      '$points',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Trade your point for free tickets or F&B',
                      style: TextStyle(
                        color: withOpacityColor(Colors.white, 0.6),
                        fontSize: 13,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: withOpacityColor(Colors.white, 0.4),
                    ),
                    onTap: () {
                      context.pushNamed(AppRoutes.rewardsRoute);
                    },
                  ),
                  const Divider(height: 1, color: Color(0xFF2C2C2C)),
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: withOpacityColor(Colors.pink, 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.local_offer_rounded,
                                color: Colors.pink,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              '${rewardService.rewards.where((r) => !r.redeemed).length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Vouchers',
                              style: TextStyle(
                                color: withOpacityColor(Colors.white, 0.6),
                                fontSize: 12,
                              ),
                            ),
                            trailing: Icon(
                              Icons.chevron_right_rounded,
                              color: withOpacityColor(Colors.white, 0.4),
                              size: 20,
                            ),
                            onTap: () {
                              context.pushNamed(AppRoutes.rewardsRoute);
                            },
                          ),
                        ),
                        Container(
                          width: 1,
                          color: const Color(0xFF2C2C2C),
                        ),
                        Expanded(
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: withOpacityColor(Colors.orange, 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.confirmation_number_rounded,
                                color: Colors.orange,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              '$couponsCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Coupons',
                              style: TextStyle(
                                color: withOpacityColor(Colors.white, 0.6),
                                fontSize: 12,
                              ),
                            ),
                            trailing: Icon(
                              Icons.chevron_right_rounded,
                              color: withOpacityColor(Colors.white, 0.4),
                              size: 20,
                            ),
                            onTap: () {
                              context.pushNamed(AppRoutes.myCouponsRoute, extra: profile.coupons);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFF2C2C2C)),
                  ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: withOpacityColor(Colors.blue, 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.badge, color: Colors.blue, size: 20),
                    ),
                    title: const Text(
                      'Member Card',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Lihat nomor kartu, barcode, dan detail belakang.',
                      style: TextStyle(color: withOpacityColor(Colors.white, 0.6), fontSize: 12),
                    ),
                    trailing: Icon(Icons.chevron_right_rounded, color: withOpacityColor(Colors.white, 0.4)),
                    onTap: () async {
                      final profileSvc = sl<ProfileService>();
                      final latest = await profileSvc.getProfile();
                      if (!mounted) return;
                      context.pushNamed(AppRoutes.memberCardRoute, extra: latest);
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMyFeaturesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'MY FEATURES',
            style: TextStyle(
              color: withOpacityColor(Colors.white, 0.5),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFeatureItem(
                context,
                'Movie\nDiary',
                Icons.movie_outlined,
                Colors.blue,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MovieDiaryView()),
                  );
                },
              ),
              _buildFeatureItem(
                context,
                'Watchlist',
                Icons.bookmark_border_rounded,
                Colors.purple,
                () {
                  // Navigate to watchlist screen
                  context.pushNamed(AppRoutes.watchlistRoute);
                },
              ),
              _buildFeatureItem(
                context,
                'Event',
                Icons.event_rounded,
                Colors.red,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EventView()),
                  );
                },
              ),
              _buildFeatureItem(
                context,
                'Free WiFi',
                Icons.wifi_rounded,
                Colors.green,
                () {
                  // Show WiFi info dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: const Color(0xFF1E1E1E),
                      title: const Row(
                        children: [
                          Icon(Icons.wifi_rounded, color: Colors.green),
                          SizedBox(width: 12),
                          Text(
                            'Free WiFi',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Connect to our free WiFi:',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Network: NNG_Cinema_Free',
                            style: TextStyle(color: withOpacityColor(Colors.white, 0.8)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Password: nngcinema2025',
                            style: TextStyle(color: withOpacityColor(Colors.white, 0.8)),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Available at all NNG Cinema locations',
                            style: TextStyle(
                              color: withOpacityColor(Colors.white, 0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: withOpacityColor(Colors.white, 0.8),
              fontSize: 12,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OTHER',
            style: TextStyle(
              color: withOpacityColor(Colors.white, 0.5),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildOtherItem(
                context,
                'FAQ & Contact Us',
                'Find the best answer to your questions',
                Icons.headset_mic_outlined,
                Colors.cyan,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FaqContactView()),
                  );
                },
              ),
              const Divider(height: 1, color: Color(0xFF2C2C2C)),
              _buildOtherItem(
                context,
                'Settings',
                'View and set your account preferences',
                Icons.settings_outlined,
                Colors.grey,
                () async {
                  // Navigate to edit profile as settings
                  final result = await context.pushNamed(
                    AppRoutes.editProfileRoute,
                    extra: await sl<ProfileService>().getProfile(),
                  );
                  if (result == true) {
                    _refreshProfile();
                  }
                },
              ),
              const Divider(height: 1, color: Color(0xFF2C2C2C)),
              // If user is anonymous, show Upgrade / Link options
              if (sl<AuthService>().currentUser?.isAnonymous == true) ...[
                _buildOtherItem(
                  context,
                  'Upgrade Account',
                  'Link your anonymous account to email',
                  Icons.upgrade_rounded,
                  Colors.teal,
                  () async {
                    final res = await _showUpgradeDialog(context);
                    if (res == true) {
                      _refreshProfile();
                    }
                  },
                ),
                const Divider(height: 1, color: Color(0xFF2C2C2C)),
                _buildOtherItem(
                  context,
                  'Link with Google',
                  'Use Google to secure your account',
                  Icons.login_rounded,
                  Colors.redAccent,
                  () async {
                    // Store navigator before async operation
                    final navigator = Navigator.of(context, rootNavigator: true);
                    final scaffoldMessenger = ScaffoldMessenger.of(context);

                    try {
                      // Show loading indicator with proper styling
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        barrierColor: Colors.black87,
                        builder: (ctx) => PopScope(
                          canPop: false,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E1E),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 16),
                                  Text('Menghubungkan ke Google...', style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );

                      final cred = await sl<AuthService>().linkAnonymousWithGoogle();

                      // Close loading dialog
                      if (navigator.canPop()) {
                        navigator.pop();
                      }

                      if (!mounted) return;

                      if (cred != null) {
                        scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Successfully linked with Google')));
                        _refreshProfile();
                      } else {
                        scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Google sign-in was cancelled')));
                      }
                    } on FirebaseAuthException catch (e) {
                      if (navigator.canPop()) navigator.pop();
                      scaffoldMessenger.showSnackBar(SnackBar(content: Text(e.message ?? e.code)));
                    } on AuthException catch (e) {
                      if (navigator.canPop()) navigator.pop();
                      if (e.code == 'google-config-missing') {
                        if (!mounted) return;
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: const Color(0xFF1E1E1E),
                            title: const Text('Google Sign-In Not Available', style: TextStyle(color: Colors.white)),
                            content: const Text(
                              'Google Sign-In belum dikonfigurasi.\n\nPastikan file google-services.json sudah dikonfigurasi dengan benar di Firebase Console.',
                              style: TextStyle(color: Colors.white70),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        scaffoldMessenger.showSnackBar(SnackBar(content: Text(e.message)));
                      }
                    } catch (e) {
                      if (navigator.canPop()) navigator.pop();
                      scaffoldMessenger.showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  },
                ),
                const Divider(height: 1, color: Color(0xFF2C2C2C)),
              ],
              _buildOtherItem(
                context,
                'Sign Out',
                'Logout from your account',
                Icons.logout_rounded,
                Colors.red,
                () {
                  // Show confirmation dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: const Color(0xFF1E1E1E),
                      title: const Text(
                        'Sign Out',
                        style: TextStyle(color: Colors.white),
                      ),
                      content: const Text(
                        'Are you sure you want to sign out?',
                        style: TextStyle(color: Colors.white70),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            try {
                              await sl<AuthService>().signOut();
                              // After sign out, navigate to sign-in using GoRouter
                              if (!mounted) return;
                              context.goNamed(AppRoutes.signInRoute);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sign out failed: $e')));
                            }
                          },
                          child: const Text(
                            'Sign Out',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOtherItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: withOpacityColor(iconColor, 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: withOpacityColor(Colors.white, 0.6),
          fontSize: 13,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: withOpacityColor(Colors.white, 0.4),
      ),
      onTap: onTap,
    );
  }

  Future<bool?> _showUpgradeDialog(BuildContext context) async {
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    bool loading = false;

    return showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text('Upgrade Account', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            StatefulBuilder(
              builder: (context, setState) {
                return TextButton(
                  onPressed: () async {
                    // show a small loading state by disabling the button while running
                    setState(() => loading = true);
                    try {
                      await sl<AuthService>().linkAnonymousWithEmail(_emailController.text.trim(), _passwordController.text);
                      Navigator.pop(context, true);
                    } on FirebaseAuthException catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? e.code)));
                    } on AuthException catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                    } finally {
                      setState(() => loading = false);
                    }
                  },
                  child: loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.teal))
                      : const Text('Upgrade', style: TextStyle(color: Colors.teal)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmSignOut() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Anda yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Keluar')),
        ],
      ),
    );

    if (ok == true) {
      await sl<AuthService>().signOut();
      if (!mounted) return;
      // After sign out, navigate to login (redirect will also trigger)
      context.goNamed(AppRoutes.signInRoute);
    }
  }
}
