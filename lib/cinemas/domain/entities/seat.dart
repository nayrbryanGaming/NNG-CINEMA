import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:movies_app/cinemas/domain/entities/seat_status.dart';

part 'seat.g.dart';

@HiveType(typeId: 5)
class Seat extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String seatNumber;

  @HiveField(2)
  final SeatStatus status;

  const Seat({
    required this.id,
    required this.seatNumber,
    this.status = SeatStatus.available,
  });

  Seat copyWith({SeatStatus? status}) {
    return Seat(
      id: id,
      seatNumber: seatNumber,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [id, seatNumber, status];
}
