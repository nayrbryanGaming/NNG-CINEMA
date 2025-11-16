import 'package:hive/hive.dart';
import 'package:movies_app/profile/domain/entities/user_profile.dart';

class ProfileService {
  static const String _boxName = 'profile';
  static const String _profileKey = 'userProfile';

  // Gets the user profile. If it doesn't exist, creates a default one.
  Future<UserProfile> getProfile() async {
    final box = await Hive.openBox<UserProfile>(_boxName);
    UserProfile? profile = box.get(_profileKey);

    if (profile == null) {
      // Create and save a default profile if one doesn't exist
      profile = UserProfile(
        userId: 'default_user_01',
        name: 'Archelaus Ryo',
        username: 'ryo_archelaus',
        profilePictureUrl: 'https://images.unsplash.com/photo-1529665253569-6d01c0eaf7b6',
        bannerUrl: 'https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0',
        usernameLastChanged: DateTime.now(),
        coupons: ['DISC10', 'FREECOFFEE'],
      );
      await box.put(_profileKey, profile);
    }
    return profile;
  }

  // Saves the updated user profile
  Future<void> saveProfile(UserProfile profile) async {
    final box = await Hive.openBox<UserProfile>(_boxName);
    await box.put(_profileKey, profile);
  }
}
