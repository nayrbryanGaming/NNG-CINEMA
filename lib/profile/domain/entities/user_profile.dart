import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 9)
class UserProfile extends Equatable {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String username;

  @HiveField(3)
  final String profilePictureUrl;

  @HiveField(4)
  final String bannerUrl;

  @HiveField(5)
  final DateTime? usernameLastChanged;

  @HiveField(6)
  final List<String> coupons;

  @HiveField(7)
  final bool hasChangedUsername;

  const UserProfile({
    required this.userId,
    required this.name,
    required this.username,
    required this.profilePictureUrl,
    required this.bannerUrl,
    this.usernameLastChanged,
    this.coupons = const [],
    this.hasChangedUsername = false,
  });

  UserProfile copyWith({
    String? name,
    String? username,
    String? profilePictureUrl,
    String? bannerUrl,
    DateTime? usernameLastChanged,
    bool? hasChangedUsername,
    List<String>? coupons,
  }) {
    return UserProfile(
      userId: userId,
      name: name ?? this.name,
      username: username ?? this.username,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      usernameLastChanged: usernameLastChanged ?? this.usernameLastChanged,
      coupons: coupons ?? this.coupons,
      hasChangedUsername: hasChangedUsername ?? this.hasChangedUsername,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        name,
        username,
        profilePictureUrl,
        bannerUrl,
        usernameLastChanged,
        coupons,
        hasChangedUsername,
      ];
}
