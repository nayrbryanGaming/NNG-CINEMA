import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:movies_app/cinemas/domain/entities/cinema.dart';
import 'package:movies_app/cinemas/domain/entities/movie_showtime.dart';
import 'package:movies_app/cinemas/domain/entities/seat.dart';

part 'ticket_order.g.dart';

@HiveType(typeId: 8)
class TicketOrder extends Equatable {
  @HiveField(0)
  final String orderId;

  @HiveField(1)
  final Cinema cinema;

  @HiveField(2)
  final MovieShowtime movieShowtime;

  @HiveField(3)
  final String selectedTime;

  @HiveField(4)
  final List<Seat> selectedSeats;

  @HiveField(5)
  final int totalPrice;

  const TicketOrder({
    required this.orderId,
    required this.cinema,
    required this.movieShowtime,
    required this.selectedTime,
    required this.selectedSeats,
    required this.totalPrice,
  });

  @override
  List<Object?> get props => [
        orderId,
        cinema,
        movieShowtime,
        selectedTime,
        selectedSeats,
        totalPrice,
      ];

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'cinema': {
        'name': cinema.name,
      },
      'movieShowtime': {
        'movieId': movieShowtime.movieId,
        'title': movieShowtime.title,
        'posterUrl': movieShowtime.posterUrl,
        'showtimes': movieShowtime.showtimes,
      },
      'selectedTime': selectedTime,
      'selectedSeats': selectedSeats.map((seat) => {
        'id': seat.id,
        'seatNumber': seat.seatNumber,
        'status': seat.status.toString(),
      }).toList(),
      'totalPrice': totalPrice,
    };
  }
}
