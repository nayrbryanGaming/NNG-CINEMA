import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:movies_app/cinemas/domain/entities/movie_showtime.dart';

part 'cinema.g.dart';

@HiveType(typeId: 7)
class Cinema extends Equatable {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String location;

  @HiveField(3)
  final List<MovieShowtime> movieShowtimes;

  const Cinema({
    required this.id,
    required this.name,
    required this.location,
    required this.movieShowtimes,
  });

  @override
  List<Object?> get props => [id, name, location, movieShowtimes];
}
