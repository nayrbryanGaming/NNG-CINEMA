import 'package:hive/hive.dart';

part 'seat_status.g.dart';

@HiveType(typeId: 4) // Assign a unique typeId
enum SeatStatus {
  @HiveField(0)
  available,

  @HiveField(1)
  occupied,

  @HiveField(2)
  selected,
}
