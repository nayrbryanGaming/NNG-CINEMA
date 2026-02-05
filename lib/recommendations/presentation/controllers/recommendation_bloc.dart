import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movies_app/core/domain/entities/media.dart';
import 'package:movies_app/core/domain/usecase/base_use_case.dart';
import 'package:movies_app/core/domain/entities/weather_info.dart';
import 'package:movies_app/core/services/weather_service.dart';
import 'package:movies_app/movies/domain/usecases/get_movies_usecase.dart';
import 'package:movies_app/recommendations/presentation/controllers/recommendation_event.dart';
import 'package:movies_app/recommendations/presentation/controllers/recommendation_state.dart';
import 'package:movies_app/search/domain/entities/search_result_item.dart';
import 'package:movies_app/search/domain/usecases/search_usecase.dart';

class RecommendationBloc extends Bloc<RecommendationEvent, RecommendationState> {
  final GetMoviesUseCase _getMoviesUseCase;
  final SearchUseCase _searchUseCase;
  final WeatherService _weatherService;

  RecommendationBloc(
    this._getMoviesUseCase,
    this._searchUseCase,
    this._weatherService,
  ) : super(RecommendationInitial()) {
    on<GetWeatherRecommendationEvent>(_onGetWeatherRecommendation);
    on<SearchEvent>(_onSearch);
  }

  String _buildReasonFromWeather(WeatherInfo info) {
    final main = (info.main ?? 'Unknown').toString();
    final desc = (info.description ?? '');
    final temp = info.temperatureCelsius != null ? '${info.temperatureCelsius!.toStringAsFixed(0)}°C' : 'suhu tidak tersedia';

    // Build a human-friendly reason in Indonesian
    final buffer = StringBuffer();
    buffer.write('Cuaca: $main');
    if (desc.isNotEmpty) buffer.write(' — ${desc[0].toUpperCase()}${desc.substring(1)}');
    buffer.write(', $temp. ');

    // Provide brief justification depending on weather conditions
    final lowTemp = info.temperatureCelsius != null && info.temperatureCelsius! < 18;
    final highTemp = info.temperatureCelsius != null && info.temperatureCelsius! >= 30;

    if (main.toLowerCase().contains('rain') || main.toLowerCase().contains('drizzle') || main.toLowerCase().contains('thunderstorm')) {
      buffer.write('Karena hujan/gerimis, dipilih film yang hangat dan populer agar nyaman ditonton di dalam ruangan.');
    } else if (lowTemp) {
      buffer.write('Karena cuaca dingin, dipilih film feel-good/top rated untuk suasana hangat.');
    } else if (highTemp) {
      buffer.write('Karena cuaca panas, dipilih film ringan dan populer untuk pengalaman yang menyenangkan.');
    } else if (main.toLowerCase().contains('clear')) {
      buffer.write('Cuaca cerah cocok untuk film yang ceria dan populer.');
    } else if (main.toLowerCase().contains('cloud')) {
      buffer.write('Cuaca berawan; rekomendasi ini memilih film yang cocok untuk suasana santai.');
    } else {
      buffer.write('Rekomendasi ini disusun berdasarkan kondisi cuaca saat ini.');
    }

    return buffer.toString();
  }

  Future<void> _onGetWeatherRecommendation(
    GetWeatherRecommendationEvent event,
    Emitter<RecommendationState> emit,
  ) async {
    emit(RecommendationLoading());
    try {
      // Pass forceRefresh to weather service - only true when user manually refreshes
      final weatherInfo = await _weatherService.getWeatherInfo(forceRefresh: event.forceRefresh);
      final allMoviesResult = await _getMoviesUseCase(const NoParameters());

      allMoviesResult.fold(
        (failure) => emit(RecommendationError(failure.message)),
        (movies) {
          final nowPlaying = movies[0];
          final popular = movies[1];
          final topRated = movies[2];

          final recommended = _getMoviesForWeatherInfo(weatherInfo, nowPlaying, popular, topRated);

          final title = weatherInfo.temperatureCelsius != null
              ? 'For ${weatherInfo.main} · ${weatherInfo.temperatureCelsius!.toStringAsFixed(0)}°C'
              : 'For ${weatherInfo.main}';

          // Build a human-readable reason directly from the WeatherInfo returned by the API
          final reason = _buildReasonFromWeather(weatherInfo);

          emit(RecommendationLoaded(recommended, title, reason: reason));
        },
      );
    } catch (e) {
      emit(const RecommendationError('Could not get weather recommendations.'));
    }
  }

  Future<void> _onSearch(SearchEvent event, Emitter<RecommendationState> emit) async {
    if (event.query.isEmpty) {
      emit(RecommendationInitial());
      return;
    }
    emit(RecommendationLoading());
    final result = await _searchUseCase(event.query);
    result.fold(
      (failure) => emit(RecommendationError(failure.message)),
      (searchResultItems) {
        final List<Media> movies = searchResultItems.map((item) => item.toMedia()).toList();
        emit(RecommendationLoaded(movies, 'Search results for "${event.query}"'));
      },
    );
  }

  List<Media> _getMoviesForWeatherInfo(
      WeatherInfo info, List<Media> now, List<Media> popular, List<Media> topRated) {
    final main = info.main;
    final temp = info.temperatureCelsius;

    // Prefer cozy/topRated when cold or stormy
    if (main == 'Rain' || main == 'Drizzle' || main == 'Thunderstorm') return topRated;

    // If temperature is available, use thresholds
    if (temp != null) {
      if (temp < 18) return topRated; // cold -> feel-good/top rated
      if (temp >= 30) return popular; // hot -> light/popular
    }

    switch (main) {
      case 'Clear':
        return popular;
      case 'Clouds':
        return now.reversed.toList();
      default:
        return popular;
    }
  }
}

// Correctly defined extension
extension on SearchResultItem {
  Media toMedia() {
    return Media(
      tmdbID: tmdbID,
      title: title,
      posterUrl: posterUrl,
      backdropUrl: ' ', // Search result doesn't have backdrop
      voteAverage: 0, // Search result doesn't have vote average
      releaseDate: ' ', // Search result doesn't have release date
      overview: ' ', // Search result doesn't have overview
      isMovie: isMovie,
    );
  }
}
