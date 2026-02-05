import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movies_app/profile/data/datasource/profile_service.dart';
import 'package:movies_app/fnb/data/fnb_order_service.dart';
import 'package:movies_app/core/services/service_locator.dart';
import 'package:movies_app/core/resources/app_routes.dart';
import 'package:movies_app/profile/data/reward_service.dart';
import 'package:movies_app/utils/notification_service.dart';

class FnbCartView extends StatefulWidget {
  final List<Map<String, dynamic>> cart;
  final ValueChanged<List<Map<String, dynamic>>> onUpdate;
  final ValueChanged<List<Map<String, dynamic>>>? onCheckout;

  const FnbCartView({super.key, required this.cart, required this.onUpdate, this.onCheckout});

  @override
  State<FnbCartView> createState() => _FnbCartViewState();
}

class _FnbCartViewState extends State<FnbCartView> {
  late List<Map<String, dynamic>> _localCart;

  @override
  void initState() {
    super.initState();
    _localCart = widget.cart.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  void _updateParent() {
    widget.onUpdate(_localCart);
  }

  int get _total => _localCart.fold<int>(0, (p, e) => p + (e['price'] as int) * (e['qty'] as int));

  void _increment(int idx) {
    setState(() {
      _localCart[idx]['qty'] = (_localCart[idx]['qty'] as int) + 1;
    });
    _updateParent();
  }

  void _decrement(int idx) {
    setState(() {
      final qty = (_localCart[idx]['qty'] as int) - 1;
      if (qty <= 0) {
        _localCart.removeAt(idx);
      } else {
        _localCart[idx]['qty'] = qty;
      }
    });
    _updateParent();
  }

  void _checkout(PaymentMethod method) {
    final total = _total;
    if (total <= 0) return;

    if (method == PaymentMethod.qris) {
      _showQrisPaymentFlow(context, total, method);
    } else if (method == PaymentMethod.bankTransfer) {
      _showBankTransferFlow(context, total, method);
    } else {
      _showEWalletFlow(context, total, method);
    }
  }

  Future<void> _completeOrder(PaymentMethod method) async {
    final orderService = sl<FnbOrderService>();
    final rewardService = sl<RewardService>();

    // Create order (now async)
    final order = await orderService.createOrderFromCart(_localCart, method);

    // Mark as paid (now async)
    await orderService.markPaid(order.id);

    // Add notification for successful F&B order
    await NotificationService.addFnbOrderNotification(order.id);

    // Add reward points
    try {
      final profile = await sl<ProfileService>().getProfile();
      await rewardService.addPoints(profile, (order.total / 10000).ceil() * 10);
    } catch (_) {}

    // Clear cart
    setState(() {
      _localCart.clear();
    });
    _updateParent();

    if (!mounted) return;

    // Show success and go to orders using GoRouter for proper bottom nav integration
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pembayaran berhasil! Pesanan dibuat.')),
    );

    // Close the cart bottom sheet first
    Navigator.of(context).pop();

    // Navigate to F&B orders using GoRouter so bottom nav stays functional
    context.goNamed(AppRoutes.fnbOrdersRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        backgroundColor: const Color(0xFF141414),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
      backgroundColor: const Color(0xFF141414),
      body: _localCart.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.shopping_cart_outlined, size: 48, color: Colors.white70),
                  SizedBox(height: 12),
                  Text('Keranjang kosong', style: TextStyle(color: Colors.white70)),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _localCart.length,
                    itemBuilder: (context, index) {
                      final item = _localCart[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF222222),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            // image
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey.shade800,
                                image: item['image'] != null ? DecorationImage(image: NetworkImage(item['image']), fit: BoxFit.cover) : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 6),
                                  Text('Rp ${_formatCurrency(item['price'])}', style: const TextStyle(color: Colors.white70)),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => _decrement(index),
                                  icon: const Icon(Icons.remove_circle_outline, color: Colors.white70),
                                ),
                                Text('${item['qty']}', style: const TextStyle(color: Colors.white)),
                                IconButton(
                                  onPressed: () => _increment(index),
                                  icon: const Icon(Icons.add_circle_outline, color: Colors.white70),
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Total: Rp ${_formatCurrency(_total)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _localCart.isNotEmpty ? _showPaymentMethodPicker : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Checkout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }

  void _showPaymentMethodPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return FractionallySizedBox(
          heightFactor: 0.5,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF141414),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pilih Metode Pembayaran', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.qr_code_2, color: Colors.white),
                  title: const Text('QRIS', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Bayar dengan aplikasi QRIS', style: TextStyle(color: Colors.white70)),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _checkout(PaymentMethod.qris);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.account_balance, color: Colors.white),
                  title: const Text('Transfer Bank', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('BCA / Mandiri / BRI / BNI', style: TextStyle(color: Colors.white70)),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _checkout(PaymentMethod.bankTransfer);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet, color: Colors.white),
                  title: const Text('E-Wallet', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('GoPay / OVO / DANA / ShopeePay', style: TextStyle(color: Colors.white70)),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _checkout(PaymentMethod.eWallet);
                  },
                ),
                const Spacer(),
                Text('Total: Rp ${_formatCurrency(_total)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showQrisPaymentFlow(BuildContext context, int amount, PaymentMethod method) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.85,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0xFF141414),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Pembayaran QRIS', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // QR Code placeholder
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Image.network(
                        'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=QRIS-FNB-NNG-$amount',
                        width: 200,
                        height: 200,
                        errorBuilder: (_, __, ___) => const Icon(Icons.qr_code_2, size: 150, color: Colors.black54),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('2NNG CINEMA F&B', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    const Text('NMID: ID1234567890123', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Pembayaran', style: TextStyle(color: Colors.white70)),
                    Text('Rp ${_formatCurrency(amount)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Scan QR di atas menggunakan aplikasi e-wallet atau mobile banking yang mendukung QRIS',
                style: TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _completeOrder(method);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Saya Sudah Bayar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBankTransferFlow(BuildContext context, int amount, PaymentMethod method) {
    final banks = [
      {'name': 'BCA', 'account': '8170 1234 5678', 'holder': '2NNG CINEMA'},
      {'name': 'Mandiri', 'account': '1570 0012 3456 789', 'holder': '2NNG CINEMA'},
      {'name': 'BRI', 'account': '0033 0100 1234 567', 'holder': '2NNG CINEMA'},
      {'name': 'BNI', 'account': '0123 4567 890', 'holder': '2NNG CINEMA'},
    ];

    int selectedBank = 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => FractionallySizedBox(
          heightFactor: 0.85,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF141414),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Transfer Bank', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Pembayaran', style: TextStyle(color: Colors.white70)),
                      Text('Rp ${_formatCurrency(amount)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Pilih Bank Tujuan:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: banks.length,
                    itemBuilder: (c, i) => GestureDetector(
                      onTap: () => setModalState(() => selectedBank = i),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: selectedBank == i ? Colors.red.withOpacity(0.2) : const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(12),
                          border: selectedBank == i ? Border.all(color: Colors.red, width: 2) : null,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(banks[i]['name']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(banks[i]['name']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text(banks[i]['account']!, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                                  Text('a/n ${banks[i]['holder']}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, color: Colors.white70, size: 20),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('No. rekening ${banks[i]['name']} disalin')),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.info_outline, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Transfer tepat sesuai nominal agar pembayaran terverifikasi otomatis.',
                          style: TextStyle(color: Colors.orange, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _completeOrder(method);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Saya Sudah Transfer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEWalletFlow(BuildContext context, int amount, PaymentMethod method) {
    final ewallets = [
      {'name': 'GoPay', 'phone': '0812-3456-7890'},
      {'name': 'OVO', 'phone': '0812-3456-7890'},
      {'name': 'DANA', 'phone': '0812-3456-7890'},
      {'name': 'ShopeePay', 'phone': '0812-3456-7890'},
    ];

    int selectedWallet = 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => FractionallySizedBox(
          heightFactor: 0.85,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF141414),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('E-Wallet', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Pembayaran', style: TextStyle(color: Colors.white70)),
                      Text('Rp ${_formatCurrency(amount)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Pilih E-Wallet:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: ewallets.length,
                    itemBuilder: (c, i) => GestureDetector(
                      onTap: () => setModalState(() => selectedWallet = i),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: selectedWallet == i ? Colors.red.withOpacity(0.2) : const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(12),
                          border: selectedWallet == i ? Border.all(color: Colors.red, width: 2) : null,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: _getWalletColor(ewallets[i]['name']!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  ewallets[i]['name']!.substring(0, 1),
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(ewallets[i]['name']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text(ewallets[i]['phone']!, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                                ],
                              ),
                            ),
                            if (selectedWallet == i)
                              const Icon(Icons.check_circle, color: Colors.red),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _completeOrder(method);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Saya Sudah Bayar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getWalletColor(String name) {
    switch (name) {
      case 'GoPay':
        return const Color(0xFF00AA13);
      case 'OVO':
        return const Color(0xFF4C3494);
      case 'DANA':
        return const Color(0xFF108EE9);
      case 'ShopeePay':
        return const Color(0xFFEE4D2D);
      default:
        return Colors.grey;
    }
  }

  String _formatCurrency(int amount) {
    final str = amount.toString();
    final result = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      result.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        result.write('.');
      }
    }
    return result.toString().split('').reversed.join('');
  }
}
