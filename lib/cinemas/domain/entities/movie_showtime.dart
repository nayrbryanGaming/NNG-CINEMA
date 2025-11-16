import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'movie_showtime.g.dart';

@HiveType(typeId: 6)
class MovieShowtime extends Equatable {
  @HiveField(0)
  final int movieId;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String posterUrl;

  @HiveField(3)
  final List<String> showtimes;

  const MovieShowtime({
    required this.movieId,
    required this.title,
    required this.posterUrl,
    required this.showtimes,
  });

  @override
  List<Object?> get props => [movieId, title, posterUrl, showtimes];
}
