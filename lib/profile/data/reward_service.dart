import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:movies_app/profile/domain/entities/user_profile.dart';

/// Reward model stored locally.
class RewardItem {
  final String id;
  final String title;
  final String description;
  final DateTime expiry;
  bool redeemed;

  RewardItem({
    required this.id,
    required this.title,
    required this.description,
    required this.expiry,
    this.redeemed = false,
  });
}

/// Local-only rewards/vouchers service.
class RewardService extends ChangeNotifier {
  static const _boxName = 'rewardsBox';
  static const _pointsKey = 'points';
  static const _rewardsKey = 'rewards';
  static const _cardKey = 'memberCard';

  static final RewardService _instance = RewardService._internal();
  factory RewardService() => _instance;
  RewardService._internal();

  /// Points balance
  int _points = 0;
  int get points => _points;

  /// Rewards list
  List<RewardItem> _rewards = [];
  List<RewardItem> get rewards => List.unmodifiable(_rewards);

  /// Member card data (back side) stored per user
  String _cardNumber = '';
  String _cardBarcode = '';

  String get cardNumber => _cardNumber;
  String get cardBarcode => _cardBarcode;

  Future<void> load(UserProfile profile) async {
    final box = await Hive.openBox(_boxName);
    _points = box.get('${_pointsKey}_${profile.userId}', defaultValue: 0) as int;
    _cardNumber = box.get('${_cardKey}_${profile.userId}_num', defaultValue: '') as String;
    _cardBarcode = box.get('${_cardKey}_${profile.userId}_bar', defaultValue: '') as String;

    final raw = box.get('${_rewardsKey}_${profile.userId}');
    if (raw is List) {
      _rewards = raw.cast<Map>()
          .map((e) => RewardItem(
                id: e['id'] as String,
                title: e['title'] as String,
                description: e['description'] as String,
                expiry: DateTime.parse(e['expiry'] as String),
                redeemed: e['redeemed'] as bool,
              ))
          .toList();
    } else {
      _rewards = [];
    }
    // Initialize member card if missing OR if it's in old format (contains letters/NNG prefix)
    if (_cardNumber.isEmpty || _isOldCardFormat(_cardNumber)) {
      _cardNumber = _generateCardNumber(profile.userId);
      _cardBarcode = _cardNumber.replaceAll('-', ''); // Barcode uses digits only
      await _persistCard(profile.userId);
    }
    notifyListeners();
  }

  /// Check if card number is in old format (contains letters or not 28 digits)
  bool _isOldCardFormat(String cardNumber) {
    // Old formats:
    // - NNG-{hashCode}-{6digits} (contains letters)
    // - 16-digit format XXXX-XXXX-XXXX-XXXX
    // New format: 28 digits XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX

    // Check if contains any letters
    if (cardNumber.contains(RegExp(r'[a-zA-Z]'))) return true;

    // Check if not exactly 28 digits (excluding dashes)
    final digitsOnly = cardNumber.replaceAll('-', '');
    if (digitsOnly.length != 28) return true;

    return false;
  }

  Future<void> _persist(UserProfile profile) async {
    final box = await Hive.openBox(_boxName);
    await box.put('${_pointsKey}_${profile.userId}', _points);
    await box.put('${_rewardsKey}_${profile.userId}', _rewards
        .map((e) => {
              'id': e.id,
              'title': e.title,
              'description': e.description,
              'expiry': e.expiry.toIso8601String(),
              'redeemed': e.redeemed,
            })
        .toList());
  }

  Future<void> _persistCard(String userId) async {
    final box = await Hive.openBox(_boxName);
    await box.put('${_cardKey}_${userId}_num', _cardNumber);
    await box.put('${_cardKey}_${userId}_bar', _cardBarcode);
  }

  String _generateCardNumber(String userId) {
    // Generate a unique 28-digit member card number (all numeric, no letters)
    // Format: XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX (28 digits with dashes)

    // Use current timestamp + user hash for uniqueness
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final userHash = userId.hashCode.abs();

    // Combine to create a seed for consistent randomness per user
    final seed = (timestamp ~/ 1000) + userHash;
    final seededRand = Random(seed);

    // Generate 28 random digits
    final digits = List.generate(28, (_) => seededRand.nextInt(10)).join();

    // Format as XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX (7 groups of 4)
    final formatted = '${digits.substring(0, 4)}-${digits.substring(4, 8)}-${digits.substring(8, 12)}-${digits.substring(12, 16)}-${digits.substring(16, 20)}-${digits.substring(20, 24)}-${digits.substring(24, 28)}';

    return formatted;
  }

  /// Earn points, e.g., after purchases.
  Future<void> addPoints(UserProfile profile, int amount) async {
    _points += amount;
    await _persist(profile);
    notifyListeners();
  }

  /// Redeem a reward; mark redeemed and deduct points (simple flat cost).
  Future<bool> redeemReward(UserProfile profile, String rewardId, {int cost = 100}) async {
    final idx = _rewards.indexWhere((r) => r.id == rewardId && !r.redeemed);
    if (idx == -1 || _points < cost) return false;
    _points -= cost;
    _rewards[idx].redeemed = true;
    await _persist(profile);
    notifyListeners();
    return true;
  }

  /// Grant a voucher/coupon to the user and persist into profile.coupons.
  Future<UserProfile> grantCoupon(UserProfile profile, String code) async {
    // Avoid duplicates
    if (profile.coupons.contains(code)) {
      return profile;
    }
    final updated = profile.copyWith(
      coupons: [...profile.coupons, code],
    );
    final box = await Hive.openBox<UserProfile>('profile');
    await box.put('userProfile', updated);
    notifyListeners();
    return updated;
  }

  /// Seed demo rewards if empty.
  Future<void> seedDefaults(UserProfile profile) async {
    if (_rewards.isNotEmpty) return;
    _rewards = [
      RewardItem(
        id: 'rw-free-popcorn',
        title: 'Free Popcorn',
        description: 'Tukar 100 poin untuk 1x popcorn M.',
        expiry: DateTime.now().add(const Duration(days: 30)),
      ),
      RewardItem(
        id: 'rw-discount-10',
        title: 'Diskon 10%',
        description: 'Diskon 10% tiket atau F&B, min. transaksi 50k.',
        expiry: DateTime.now().add(const Duration(days: 60)),
      ),
    ];
    await _persist(profile);
    notifyListeners();
  }
}

