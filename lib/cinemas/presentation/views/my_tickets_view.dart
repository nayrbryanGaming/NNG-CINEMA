import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movies_app/cinemas/data/datasource/ticket_service.dart';
import 'package:movies_app/cinemas/domain/entities/ticket_order.dart';
import 'package:movies_app/core/resources/app_routes.dart';
import 'package:movies_app/core/services/service_locator.dart';

class MyTicketsView extends StatefulWidget {
  const MyTicketsView({super.key});

  @override
  State<MyTicketsView> createState() => _MyTicketsViewState();
}

class _MyTicketsViewState extends State<MyTicketsView> {
  late Future<List<TicketOrder>> _ticketsFuture;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  void _loadTickets() {
    final ticketService = sl<TicketService>();
    setState(() {
      _ticketsFuture = ticketService.getTickets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tickets'),
      ),
      body: FutureBuilder<List<TicketOrder>>(
        future: _ticketsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load tickets.'));
          }

          final tickets = snapshot.data;
          if (tickets == null || tickets.isEmpty) {
            return const Center(
              child: Text(
                'You have no active tickets.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    context.pushNamed(AppRoutes.ticketDetailsRoute, extra: ticket);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ticket.movieShowtime.title, style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 8),
                        Text(ticket.cinema.name, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text('Today, ${ticket.selectedTime}', style: Theme.of(context).textTheme.bodyLarge),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Seats: ${ticket.selectedSeats.map((s) => s.seatNumber).join(', ')}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const Icon(Icons.qr_code_2_rounded, size: 50, color: Colors.black87),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
