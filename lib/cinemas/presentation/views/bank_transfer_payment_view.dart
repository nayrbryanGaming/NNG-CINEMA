import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:movies_app/cinemas/domain/entities/ticket_order.dart';
import 'package:movies_app/cinemas/data/datasource/ticket_service.dart';
import 'package:movies_app/core/services/service_locator.dart';
import 'package:movies_app/core/resources/app_routes.dart';

class BankTransferPaymentView extends StatefulWidget {
  final TicketOrder order;

  const BankTransferPaymentView({super.key, required this.order});

  @override
  State<BankTransferPaymentView> createState() => _BankTransferPaymentViewState();
}

class _BankTransferPaymentViewState extends State<BankTransferPaymentView> {
  bool _isProcessing = false;

  final List<Map<String, String>> banks = [
    {'name': 'BCA', 'account': '123-456-7890', 'beneficiary': 'NNG Cinema'},
    {'name': 'Mandiri', 'account': '987-654-3210', 'beneficiary': 'NNG Cinema'},
    {'name': 'BRI', 'account': '111-222-333', 'beneficiary': 'NNG Cinema'},
    {'name': 'BNI', 'account': '444-555-666', 'beneficiary': 'NNG Cinema'},
  ];

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank Transfer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount to transfer', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(currencyFormat.format(widget.order.totalPrice), style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('Choose your bank and transfer to the account below:', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemBuilder: (context, index) {
                  final bank = banks[index];
                  return ListTile(
                    tileColor: const Color(0xFF1E1E1E),
                    title: Text(bank['name']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    subtitle: Text('${bank['beneficiary']} - ${bank['account']}', style: const TextStyle(color: Colors.white70)),
                    trailing: IconButton(
                      icon: const Icon(Icons.copy, color: Colors.white70),
                      onPressed: () {
                        // copy to clipboard
                        // Using Flutter's clipboard API
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Account ${bank['account']} copied')));
                      },
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemCount: banks.length,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing
                    ? null
                    : () async {
                        setState(() => _isProcessing = true);
                        try {
                          final ticketService = sl<TicketService>();
                          await ticketService.saveTicket(widget.order);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment recorded.')));
                            await Future.delayed(const Duration(milliseconds: 300));
                            if (mounted) context.goNamed(AppRoutes.myTicketsRoute);
                          }
                        } catch (e) {
                          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                        } finally {
                          if (mounted) setState(() => _isProcessing = false);
                        }
                      },
                child: _isProcessing ? const CircularProgressIndicator() : const Text('I Have Transferred'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

