import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movies_app/core/domain/entities/media.dart';
import 'package:movies_app/core/domain/usecase/base_use_case.dart';
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

  Future<void> _onGetWeatherRecommendation(
    GetWeatherRecommendationEvent event,
    Emitter<RecommendationState> emit,
  ) async {
    emit(RecommendationLoading());
    try {
      final weatherCondition = await _weatherService.getCurrentWeather();
      // Corrected to use NoParameters()
      final allMoviesResult = await _getMoviesUseCase(const NoParameters());

      allMoviesResult.fold(
        (failure) => emit(RecommendationError(failure.message)),
        (movies) {
          final nowPlaying = movies[0];
          final popular = movies[1];
          final topRated = movies[2];
          final recommended = _getMoviesForWeather(weatherCondition, nowPlaying, popular, topRated);
          emit(RecommendationLoaded(recommended, 'For a $weatherCondition Day'));
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

  List<Media> _getMoviesForWeather(
      String? weather, List<Media> now, List<Media> popular, List<Media> topRated) {
    switch (weather) {
      case 'Rain':
      case 'Drizzle':
      case 'Thunderstorm':
        return topRated;
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
