import 'package:flutter/material.dart';
import 'dart:math';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:movies_app/cinemas/domain/entities/cinema.dart';
import 'package:movies_app/cinemas/domain/entities/movie_showtime.dart';
import 'package:movies_app/cinemas/domain/entities/seat.dart';
import 'package:movies_app/cinemas/domain/entities/seat_status.dart';
import 'package:movies_app/cinemas/domain/entities/ticket_order.dart';
import 'package:movies_app/core/resources/app_colors.dart';
import 'package:movies_app/core/resources/app_routes.dart';

class SeatSelectionView extends StatefulWidget {
  final Cinema cinema;
  final MovieShowtime movieShowtime;
  final String selectedTime;

  const SeatSelectionView({
    super.key,
    required this.cinema,
    required this.movieShowtime,
    required this.selectedTime,
  });

  @override
  State<SeatSelectionView> createState() => _SeatSelectionViewState();
}

class _SeatSelectionViewState extends State<SeatSelectionView> {
  late List<Seat> _seats;
  final List<Seat> _selectedSeats = [];
  final int _pricePerSeat = 50000;

  @override
  void initState() {
    super.initState();
    _seats = _generateDummySeats();
  }

  List<Seat> _generateDummySeats() {
    final seats = <Seat>[];
    const rows = 8;
    const cols = 9;
    final random = Random();

    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        final seatNumber = '${String.fromCharCode(65 + i)}${j + 1}';
        final isOccupied = random.nextInt(5) == 0;
        seats.add(Seat(
          id: seatNumber,
          seatNumber: seatNumber,
          status: isOccupied ? SeatStatus.occupied : SeatStatus.available,
        ));
      }
    }
    return seats;
  }

  void _onSeatTap(int index) {
    final seat = _seats[index];
    if (seat.status == SeatStatus.occupied) return;

    setState(() {
      if (seat.status == SeatStatus.available) {
        _seats[index] = seat.copyWith(status: SeatStatus.selected);
        _selectedSeats.add(_seats[index]);
      } else if (seat.status == SeatStatus.selected) {
        _seats[index] = seat.copyWith(status: SeatStatus.available);
        _selectedSeats.removeWhere((s) => s.id == seat.id);
      }
    });
  }

  Color _getSeatColor(SeatStatus status) {
    switch (status) {
      case SeatStatus.available:
        return const Color(0xFF4A4A4A); // Dark grey for available seats
      case SeatStatus.occupied:
        return Colors.grey.shade800; // Even darker for occupied
      case SeatStatus.selected:
        return AppColors.primary; // Use the primary red for selected
    }
  }

  String _getFormattedDate() {
    return DateFormat('E, d MMM').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final total = _selectedSeats.length * _pricePerSeat;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.movieShowtime.title),
            Text(
              '${widget.cinema.name} | ${_getFormattedDate()}, ${widget.selectedTime}',
              style: Theme.of(context).textTheme.bodyMedium, // Use bodyMedium for subtitle
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.tertiaryText,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.tertiaryText.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                ),
              ],
            ),
          ),
          const Text('Screen'),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 9,
                childAspectRatio: 1.0,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _seats.length,
              itemBuilder: (context, index) {
                final seat = _seats[index];
                return GestureDetector(
                  onTap: () => _onSeatTap(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getSeatColor(seat.status),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Text(
                        seat.seatNumber,
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: seat.status == SeatStatus.occupied ? Colors.black54 : AppColors.primaryText,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          _buildLegend(),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Price'),
                    Text(
                      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(total),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: _selectedSeats.isNotEmpty
                      ? () {
                          final order = TicketOrder(
                            orderId: 'CGV-${widget.movieShowtime.movieId}-${DateTime.now().millisecondsSinceEpoch}-${(Random().nextInt(9000)+1000)}',
                            cinema: widget.cinema,
                            movieShowtime: widget.movieShowtime,
                            selectedTime: widget.selectedTime,
                            selectedSeats: _selectedSeats,
                            totalPrice: total,
                          );
                          context.pushNamed(AppRoutes.orderSummaryRoute, extra: order);
                        }
                      : null,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Text('Buy Ticket'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _legendItem(SeatStatus.available, 'Available'),
        _legendItem(SeatStatus.selected, 'Selected'),
        _legendItem(SeatStatus.occupied, 'Occupied'),
      ],
    );
  }

  Widget _legendItem(SeatStatus status, String label) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: _getSeatColor(status),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
