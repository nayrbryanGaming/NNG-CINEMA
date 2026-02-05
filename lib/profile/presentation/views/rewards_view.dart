import 'package:flutter/material.dart';
import 'package:movies_app/profile/data/reward_service.dart';
import 'package:movies_app/profile/domain/entities/user_profile.dart';
import 'package:movies_app/core/resources/app_routes.dart';
import 'package:movies_app/core/services/service_locator.dart';
import 'package:go_router/go_router.dart';

class RewardsView extends StatefulWidget {
  final UserProfile profile;
  const RewardsView({super.key, required this.profile});

  @override
  State<RewardsView> createState() => _RewardsViewState();
}

class _RewardsViewState extends State<RewardsView> {
  late RewardService _rewardService;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _rewardService = sl<RewardService>();
    _rewardService.addListener(_onChanged);
    _init();
  }

  @override
  void dispose() {
    _rewardService.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _init() async {
    await _rewardService.load(widget.profile);
    await _rewardService.seedDefaults(widget.profile);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _redeem(RewardItem item) async {
    final ok = await _rewardService.redeemReward(widget.profile, item.id, cost: 100);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reward redeemed. Voucher ditambahkan.')));
      // grant coupon with same code as reward id
      await _rewardService.grantCoupon(widget.profile, item.id.toUpperCase());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Poin tidak cukup atau reward sudah dipakai.')));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF141414),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final rewards = _rewardService.rewards;
    final points = _rewardService.points;

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        title: const Text('My Rewards'),
        backgroundColor: const Color(0xFF141414),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 8),
                Text('Points: $points', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton(
                  onPressed: () => context.pushNamed(AppRoutes.memberCardRoute, extra: widget.profile),
                  child: const Text('Member Card'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: rewards.length,
              itemBuilder: (context, idx) {
                final item = rewards[idx];
                final expired = item.expiry.isBefore(DateTime.now());
                final insufficientPoints = points < 100;
                final canRedeem = !item.redeemed && !expired && !insufficientPoints;
                return Card(
                  color: const Color(0xFF1E1E1E),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(item.title, style: const TextStyle(color: Colors.white)),
                    subtitle: Text('${item.description}\nExp: ${item.expiry.toLocal().toString().substring(0, 16)}${insufficientPoints && !item.redeemed ? '\n⚠️ Poin tidak cukup (min. 100)' : ''}',
                        style: const TextStyle(color: Colors.white70)),
                    trailing: ElevatedButton(
                      onPressed: canRedeem ? () => _redeem(item) : null,
                      child: Text(item.redeemed ? 'Redeemed' : 'Redeem'),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

