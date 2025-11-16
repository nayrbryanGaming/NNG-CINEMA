import 'package:flutter/material.dart';

class MyCouponsView extends StatelessWidget {
  final List<String> coupons;

  const MyCouponsView({super.key, required this.coupons});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Coupons'),
      ),
      body: coupons.isEmpty
          ? const Center(
              child: Text(
                'You have no coupons available.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: coupons.length,
              itemBuilder: (context, index) {
                final coupon = coupons[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.confirmation_number_outlined, color: Colors.green),
                    title: Text(coupon, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: const Text('Valid until 31 Dec 2024'), // Dummy expiry date
                  ),
                );
              },
            ),
    );
  }
}
