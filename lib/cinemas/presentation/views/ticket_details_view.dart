import 'package:flutter/material.dart';
import 'package:movies_app/cinemas/domain/entities/ticket_order.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TicketDetailsView extends StatelessWidget {
  final TicketOrder ticket;

  const TicketDetailsView({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Ticket'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 8.0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(ticket.movieShowtime.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  Text(ticket.cinema.name, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  QrImageView(
                    data: ticket.orderId, // The QR code will contain the unique order ID
                    version: QrVersions.auto,
                    size: 200.0,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 24),
                  Text('Seats: ${ticket.selectedSeats.map((s) => s.seatNumber).join(', ')}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('${ticket.selectedTime} | Today', style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
