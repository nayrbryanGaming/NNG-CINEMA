import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movies_app/core/presentation/components/loading_indicator.dart';
import 'package:movies_app/core/presentation/components/shimmer_image.dart';
import 'package:movies_app/core/resources/app_routes.dart';
import 'package:movies_app/core/services/service_locator.dart';
import 'package:movies_app/profile/data/datasource/profile_service.dart';
import 'package:movies_app/profile/domain/entities/user_profile.dart';

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
      body: FutureBuilder<UserProfile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Failed to load profile.'));
          }

          final profile = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 250,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: ShimmerImage(
                          imageUrl: profile.bannerUrl,
                          width: double.infinity,
                          height: 250,
                        ),
                      ),
                      Positioned(
                        bottom: -50,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                          child: ClipOval(
                            child: ShimmerImage(
                              imageUrl: profile.profilePictureUrl,
                              width: 110,
                              height: 110,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),

                Center(
                  child: Column(
                    children: [
                      Text(profile.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('@${profile.username}', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      _buildProfileButton(context, 'Edit Profile', Icons.edit_rounded, () async {
                        final result = await context.pushNamed(AppRoutes.editProfileRoute, extra: profile);
                        if (result == true) {
                          _refreshProfile();
                        }
                      }),
                      const SizedBox(height: 12),
                      _buildProfileButton(context, 'My Coupons (${profile.coupons.length})', Icons.confirmation_number_rounded, () {
                        context.pushNamed(AppRoutes.myCouponsRoute, extra: profile.coupons);
                      }),
                      const SizedBox(height: 12),
                      _buildProfileButton(context, 'Sign Out', Icons.logout_rounded, () {}, isDestructive: true),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileButton(BuildContext context, String title, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    final color = isDestructive ? Colors.red.shade700 : Theme.of(context).textTheme.bodyLarge?.color;
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        trailing: Icon(Icons.arrow_forward_ios_rounded, color: color, size: 18),
        onTap: onTap,
      ),
    );
  }
}
