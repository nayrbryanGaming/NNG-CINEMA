import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movies_app/cinemas/data/datasource/ticket_service.dart';
import 'package:movies_app/cinemas/domain/entities/ticket_order.dart';
import 'package:movies_app/core/resources/app_routes.dart';
import 'package:movies_app/core/services/service_locator.dart';

class QrisPaymentView extends StatelessWidget {
  final TicketOrder order;

  const QrisPaymentView({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay with QRIS'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Scan this QR code with your favorite e-wallet app.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              // Dummy QR Code Image
              Image.network(
                'https://upload.wikimedia.org/wikipedia/commons/d/d0/QR_code_for_mobile_English_Wikipedia.svg',
                width: 250,
                height: 250,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                onPressed: () async { // Make onPressed async
                  // 1. Save the ticket
                  final ticketService = sl<TicketService>();
                  await ticketService.saveTicket(order); // Await the save operation

                  // 2. Navigate to My Tickets page and clear the stack
                  // Use context.goNamed to ensure the navigation stack is cleared properly
                  if (context.mounted) {
                    context.goNamed(AppRoutes.myTicketsRoute);
                  }
                },
                child: const Text('I Have Paid', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
