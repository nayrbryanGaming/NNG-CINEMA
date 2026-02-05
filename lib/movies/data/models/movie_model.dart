import 'package:movies_app/core/domain/entities/media.dart';
import 'package:movies_app/core/utils/functions.dart';

class MovieModel extends Media {
  const MovieModel({
    required super.tmdbID,
    required super.title,
    required super.posterUrl,
    required super.backdropUrl,
    required super.voteAverage,
    required super.releaseDate,
    required super.overview,
    required super.isMovie,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) => MovieModel(
        tmdbID: json['id'],
        title: json['title'],
        posterUrl: getPosterUrl(json['poster_path']),
        backdropUrl: getBackdropUrl(json['backdrop_path']),
        voteAverage: double.parse((json['vote_average']).toStringAsFixed(1)),
        releaseDate: getDate(json['release_date']),
        overview: json['overview'] ?? '',
        isMovie: true,
      );

  /// Convert to JSON for cache storage
  Map<String, dynamic> toJson() => {
        'id': tmdbID,
        'title': title,
        'poster_path': posterUrl.isNotEmpty ? posterUrl.split('/').last : null,
        'backdrop_path': backdropUrl.isNotEmpty ? backdropUrl.split('/').last : null,
        'vote_average': voteAverage,
        'release_date': releaseDate,
        'overview': overview,
      };
}
