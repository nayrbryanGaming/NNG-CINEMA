import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies_app/core/domain/entities/media.dart';
import 'package:movies_app/core/data/error/failure.dart';
import 'package:movies_app/recommendations/presentation/controllers/recommendation_bloc.dart';
import 'package:movies_app/recommendations/presentation/controllers/recommendation_event.dart';
import 'package:movies_app/recommendations/presentation/controllers/recommendation_state.dart';
import 'package:movies_app/movies/domain/usecases/get_movies_usecase.dart';
import 'package:movies_app/movies/domain/repository/movies_repository.dart';
import 'package:movies_app/search/domain/usecases/search_usecase.dart';
import 'package:movies_app/search/domain/repository/search_repository.dart';
import 'package:movies_app/core/services/weather_service.dart';
import 'package:movies_app/search/domain/entities/search_result_item.dart';
import 'package:movies_app/core/domain/entities/media_details.dart';

// Fake repository implementations
class DummyMoviesRepository implements MoviesRespository {
  final List<List<Media>> movies;
  DummyMoviesRepository(this.movies);

  @override
  Future<Either<Failure, List<List<Media>>>> getMovies() async {
    return Right(movies);
  }

  @override
  Future<Either<Failure, MediaDetails>> getMovieDetails(int movieId) async {
    // return a simple MediaDetails with same media as similar
    final md = MediaDetails(
      tmdbID: 0,
      title: 'Dummy',
      posterUrl: '',
      backdropUrl: '',
      releaseDate: '',
      genres: '',
      overview: '',
      voteAverage: 0,
      voteCount: '0',
      trailerUrl: '',
      similar: movies.isNotEmpty ? movies[0] : [],
    );
    return Right(md);
  }

  @override
  Future<Either<Failure, List<Media>>> getAllPopularMovies(int page) async {
    return Right(movies.isNotEmpty ? movies[1] : []);
  }

  @override
  Future<Either<Failure, List<Media>>> getAllTopRatedMovies(int page) async {
    return Right(movies.isNotEmpty ? movies[2] : []);
  }
}

class DummySearchRepository implements SearchRepository {
  final List<SearchResultItem> results;
  DummySearchRepository(this.results);

  @override
  Future<Either<Failure, List<SearchResultItem>>> search(String query) async {
    return Right(results);
  }
}

class FakeWeatherService extends WeatherService {
  final String _weather;
  FakeWeatherService(this._weather) : super(apiKey: '');

  @override
  Future<String> getCurrentWeather() async => _weather;
}

void main() {
  group('RecommendationBloc', () {
    test('emits loading then loaded with weather-based recommendations', () async {
      final media = Media(
        tmdbID: 1,
        title: 'A',
        posterUrl: '',
        backdropUrl: '',
        voteAverage: 8.0,
        releaseDate: '',
        overview: '',
        isMovie: true,
      );
      final movies = [ [media], [media], [media] ];

      final getMoviesUseCase = GetMoviesUseCase(DummyMoviesRepository(movies));
      final searchUseCase = SearchUseCase(DummySearchRepository([]));
      final weatherService = FakeWeatherService('Clear');

      final bloc = RecommendationBloc(getMoviesUseCase, searchUseCase, weatherService);

      final expected = [
        isA<RecommendationLoading>(),
        isA<RecommendationLoaded>(),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));

      bloc.add(GetWeatherRecommendationEvent());
    });
  });
}
