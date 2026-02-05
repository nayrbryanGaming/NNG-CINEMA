import 'package:hive/hive.dart';
import 'package:movies_app/profile/domain/entities/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  static const String _boxName = 'profile';
  static const String _profileKey = 'userProfile';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Default profile placeholder - standard contact avatar
  static const String defaultProfilePlaceholder =
      'https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y';

  /// Gets the current authenticated user ID or null
  String? get _currentUserId => _auth.currentUser?.uid;

  // Gets the user profile. If it doesn't exist, creates a default one.
  Future<UserProfile> getProfile() async {
    final box = await Hive.openBox<UserProfile>(_boxName);
    UserProfile? profile = box.get(_profileKey);

    // Get current user info from Firebase Auth
    final currentUser = _auth.currentUser;
    final userId = currentUser?.uid ?? 'guest_${DateTime.now().millisecondsSinceEpoch}';
    final userEmail = currentUser?.email ?? 'guest@nng.cinema';
    final userName = currentUser?.displayName ?? userEmail;
    final userPhotoUrl = currentUser?.photoURL ?? '';

    if (profile == null || profile.userId != userId) {
      // Try to fetch from Firestore first if user is authenticated
      if (currentUser != null) {
        final firestoreProfile = await fetchAndSyncProfileFromFirestore(userId);
        if (firestoreProfile != null) {
          return firestoreProfile;
        }
      }

      // Create new profile with authenticated user data
      profile = UserProfile(
        userId: userId,
        name: userName,
        username: userEmail,
        profilePictureUrl: userPhotoUrl.isNotEmpty
            ? userPhotoUrl
            : defaultProfilePlaceholder,
        bannerUrl: 'https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0?w=800',
        usernameLastChanged: null,
        coupons: ['WELCOME10'],
        hasChangedUsername: false,
      );
      await box.put(_profileKey, profile);

      // Also save to Firestore if authenticated
      if (currentUser != null) {
        await _saveProfileToFirestore(profile);
      }
    }
    return profile;
  }

  // Saves the updated user profile
  Future<void> saveProfile(UserProfile profile) async {
    final box = await Hive.openBox<UserProfile>(_boxName);
    await box.put(_profileKey, profile);

    // Also save to Firestore if user is authenticated
    if (_currentUserId != null) {
      await _saveProfileToFirestore(profile);
    }
  }

  // Save profile to Firestore
  Future<void> _saveProfileToFirestore(UserProfile profile) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(profile.userId).set({
        'name': profile.name,
        'username': profile.username,
        'photoUrl': profile.profilePictureUrl,
        'bannerUrl': profile.bannerUrl,
        'hasChangedUsername': profile.hasChangedUsername,
        'usernameLastChanged': profile.usernameLastChanged != null
            ? Timestamp.fromDate(profile.usernameLastChanged!)
            : null,
        'coupons': profile.coupons,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      // Silently fail - local storage is still working
      print('[ProfileService] Failed to sync to Firestore: $e');
    }
  }

  // Logic: hanya bisa ganti username jika belum pernah, atau sudah lewat 30 hari
  Future<bool> canChangeUsername(UserProfile profile) async {
    if (!profile.hasChangedUsername) return true;
    if (profile.usernameLastChanged == null) return true;
    final now = DateTime.now();
    final lastChanged = profile.usernameLastChanged!;
    return now.difference(lastChanged).inDays >= 30;
  }

  // Logic: update username, set hasChangedUsername true, update timestamp
  Future<UserProfile> updateUsername(UserProfile profile, String newUsername) async {
    final now = DateTime.now();
    final updated = profile.copyWith(
      username: newUsername,
      hasChangedUsername: true,
      usernameLastChanged: now,
    );
    await saveProfile(updated);
    return updated;
  }

  // Fetch user profile from Firestore and update Hive
  Future<UserProfile?> fetchAndSyncProfileFromFirestore(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      final data = doc.data()!;

      // Parse coupons list
      List<String> coupons = [];
      if (data['coupons'] is List) {
        coupons = (data['coupons'] as List).map((e) => e.toString()).toList();
      }

      final photoUrl = data['photoUrl'] ?? '';

      final profile = UserProfile(
        userId: userId,
        name: data['name'] ?? '',
        username: data['username'] ?? '',
        profilePictureUrl: photoUrl.isNotEmpty ? photoUrl : defaultProfilePlaceholder,
        bannerUrl: data['bannerUrl'] ?? 'https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0?w=800',
        usernameLastChanged: (data['usernameLastChanged'] != null)
            ? (data['usernameLastChanged'] as Timestamp).toDate()
            : null,
        coupons: coupons,
        hasChangedUsername: data['hasChangedUsername'] ?? false,
      );

      // Save to local storage
      final box = await Hive.openBox<UserProfile>(_boxName);
      await box.put(_profileKey, profile);

      return profile;
    } catch (e) {
      print('[ProfileService] Failed to fetch from Firestore: $e');
      return null;
    }
  }

  /// Clear local profile (call on sign out)
  Future<void> clearLocalProfile() async {
    final box = await Hive.openBox<UserProfile>(_boxName);
    await box.delete(_profileKey);
  }
}
