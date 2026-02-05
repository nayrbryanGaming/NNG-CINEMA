import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movies_app/cinemas/domain/entities/ticket_order.dart';
import 'package:movies_app/core/resources/app_routes.dart';

class OrderSummaryView extends StatelessWidget {
  final TicketOrder order;

  const OrderSummaryView({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return StatefulBuilder(builder: (context, setState) {
      int fnbTotal = 0;

      return Scaffold(
        appBar: AppBar(
          title: const Text('Order Summary'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(order.movieShowtime.title, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(order.cinema.name, style: textTheme.titleMedium),
              Text('Today, ${order.selectedTime}', style: textTheme.titleMedium),
              const SizedBox(height: 24),
              Text('Seats: ${order.selectedSeats.map((s) => s.seatNumber).join(', ')}', style: textTheme.titleLarge),
              const Divider(height: 40),
              Text('Payment Method', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildPaymentMethodTile(context, 'E-Wallet', 'GoPay, OVO, etc.', Icons.account_balance_wallet, () {
                // TODO: Implement E-Wallet payment simulation
              }),
              const SizedBox(height: 12),
              _buildPaymentMethodTile(context, 'Tambah F&B', 'Pilih makanan & minuman sebelum bayar', Icons.fastfood, () async {
                // Navigate to nested F&B selection inside booking flow and await selected cart
                final result = await context.pushNamed(AppRoutes.fnbSelectionRoute, extra: order);
                if (result is List<dynamic>) {
                  // Convert dynamic to List<Map<String,dynamic>>
                  final cart = result.cast<Map<String, dynamic>>();
                  setState(() {
                    fnbTotal = cart.fold<int>(0, (p, e) => p + (e['price'] as int) * (e['qty'] as int));
                  });
                }
              }),
              const SizedBox(height: 12),
              _buildPaymentMethodTile(context, 'Bank Transfer', 'Transfer via bank (BCA/Mandiri/BRI)', Icons.account_balance, () {
                context.pushNamed(AppRoutes.bankTransferRoute, extra: order);
              }),
              _buildPaymentMethodTile(context, 'QRIS', 'Pay with any QRIS-supported app', Icons.qr_code_2, () {
                context.pushNamed(AppRoutes.qrisPaymentRoute, extra: order);
              }),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: textTheme.titleLarge),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (fnbTotal > 0) Text('Tickets: Rp${order.totalPrice}'),
                      if (fnbTotal > 0) Text('F&B: Rp$fnbTotal'),
                      Text('Rp${(order.totalPrice + fnbTotal)}', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPaymentMethodTile(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 40),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
