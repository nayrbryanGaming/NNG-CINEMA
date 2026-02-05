import 'package:get_it/get_it.dart';
import 'package:flutter/foundation.dart';
import 'package:movies_app/cinemas/data/datasource/cinema_local_data_source.dart';
import 'package:movies_app/cinemas/data/datasource/ticket_service.dart';
import 'package:movies_app/cinemas/data/repository/cinema_repository_impl.dart';
import 'package:movies_app/cinemas/domain/repository/cinema_repository.dart';
import 'package:movies_app/cinemas/domain/usecases/get_cinemas_usecase.dart';
import 'package:movies_app/cinemas/presentation/controllers/cinemas_bloc/cinemas_bloc.dart';
import 'package:movies_app/core/services/weather_service.dart';
import 'package:movies_app/movies/data/datasource/movies_remote_data_source.dart';
import 'package:movies_app/movies/data/datasource/movies_cache_service.dart';
import 'package:movies_app/movies/data/repository/movies_repository_impl.dart';
import 'package:movies_app/movies/domain/repository/movies_repository.dart';
import 'package:movies_app/movies/domain/usecases/get_all_popular_movies_usecase.dart';
import 'package:movies_app/movies/domain/usecases/get_all_top_rated_movies_usecase.dart';
import 'package:movies_app/movies/domain/usecases/get_movie_details_usecase.dart';
import 'package:movies_app/movies/domain/usecases/get_movies_usecase.dart';
import 'package:movies_app/movies/presentation/controllers/popular_movies_bloc/popular_movies_bloc.dart';
import 'package:movies_app/movies/presentation/controllers/top_rated_movies_bloc/top_rated_movies_bloc.dart';
import 'package:movies_app/profile/data/datasource/profile_service.dart';
import 'package:movies_app/profile/data/reward_service.dart';
import 'package:movies_app/recommendations/presentation/controllers/recommendation_bloc.dart';
import 'package:movies_app/search/data/datasource/search_remote_data_source.dart';
import 'package:movies_app/search/data/repository/search_repository_impl.dart';
import 'package:movies_app/search/domain/repository/search_repository.dart';
import 'package:movies_app/search/domain/usecases/search_usecase.dart';
import 'package:movies_app/search/presentation/controllers/search_bloc/search_bloc.dart';
import 'package:movies_app/tv_shows/data/datasource/tv_shows_remote_data_source.dart';
import 'package:movies_app/tv_shows/data/repository/tv_shows_repository_impl.dart';
import 'package:movies_app/tv_shows/domain/repository/tv_shows_repository.dart';
import 'package:movies_app/tv_shows/domain/usecases/get_all_popular_tv_shows_usecase.dart';
import 'package:movies_app/tv_shows/domain/usecases/get_all_top_rated_tv_shows_usecase.dart';
import 'package:movies_app/tv_shows/domain/usecases/get_season_details_usecase.dart';
import 'package:movies_app/tv_shows/domain/usecases/get_tv_show_details_usecase.dart';
import 'package:movies_app/tv_shows/domain/usecases/get_tv_shows_usecase.dart';
import 'package:movies_app/tv_shows/presentation/controllers/popular_tv_shows_bloc/popular_tv_shows_bloc.dart';
import 'package:movies_app/tv_shows/presentation/controllers/top_rated_tv_shows_bloc/top_rated_tv_shows_bloc.dart';
import 'package:movies_app/tv_shows/presentation/controllers/tv_show_details_bloc/tv_show_details_bloc.dart';
import 'package:movies_app/tv_shows/presentation/controllers/tv_shows_bloc/tv_shows_bloc.dart';

import 'package:movies_app/movies/presentation/controllers/movie_details_bloc/movie_details_bloc.dart';
import 'package:movies_app/movies/presentation/controllers/movies_bloc/movies_bloc.dart';
import 'package:movies_app/watchlist/data/datasource/watchlist_local_data_source.dart';
import 'package:movies_app/watchlist/data/repository/watchlist_repository_impl.dart';
import 'package:movies_app/watchlist/domain/repository/watchlist_repository.dart';
import 'package:movies_app/watchlist/domain/usecases/add_watchlist_item_usecase.dart';
import 'package:movies_app/watchlist/domain/usecases/check_if_item_added_usecase.dart';
import 'package:movies_app/watchlist/domain/usecases/get_watchlist_items_usecase.dart';
import 'package:movies_app/watchlist/domain/usecases/remove_watchlist_item_usecase.dart';
import 'package:movies_app/watchlist/presentation/controllers/watchlist_bloc/watchlist_bloc.dart';
import 'package:movies_app/core/services/firebase_watchlist_sync_service.dart';
import 'package:movies_app/core/services/auth_service.dart';
import 'package:movies_app/core/services/local_credential_service.dart';
import 'package:movies_app/core/services/local_admin_service.dart';
import 'package:movies_app/core/services/auth_state_notifier.dart';
import 'package:http/http.dart' as http;
import 'package:movies_app/fnb/data/fnb_order_service.dart';

final sl = GetIt.instance;

class ServiceLocator {
  static void init() {
    // Cache Services
    sl.registerLazySingleton<MoviesCacheService>(() => MoviesCacheService());

    // Data source
    sl.registerLazySingleton<MoviesRemoteDataSource>(
        () => MoviesRemoteDataSourceImpl());
    sl.registerLazySingleton<TVShowsRemoteDataSource>(
        () => TVShowsRemoteDataSourceImpl());
    sl.registerLazySingleton<SearchRemoteDataSource>(
        () => SearchRemoteDataSourceImpl());
    sl.registerLazySingleton<WatchlistLocalDataSource>(
        () => WatchlistLocalDataSourceImpl());
    sl.registerLazySingleton<CinemaLocalDataSource>(() => CinemaLocalDataSourceImpl());

    // Repository
    sl.registerLazySingleton<MoviesRespository>(
        () => MoviesRepositoryImpl(sl()));
    sl.registerLazySingleton<TVShowsRepository>(
        () => TVShowsRepositoryImpl(sl()));
    sl.registerLazySingleton<SearchRepository>(
        () => SearchRepositoryImpl(sl()));
    sl.registerLazySingleton<WatchlistRepository>(
        () => WatchListRepositoryImpl(sl()));
    sl.registerLazySingleton<CinemaRepository>(
        () => CinemaRepositoryImpl(localDataSource: sl()));

    // Use Cases
    sl.registerLazySingleton(() => GetMoviesDetailsUseCase(sl()));
    sl.registerLazySingleton(() => GetMoviesUseCase(sl()));
    sl.registerLazySingleton(() => GetAllPopularMoviesUseCase(sl()));
    sl.registerLazySingleton(() => GetAllTopRatedMoviesUseCase(sl()));
    sl.registerLazySingleton(() => GetTVShowsUseCase(sl()));
    sl.registerLazySingleton(() => GetTVShowDetailsUseCase(sl()));
    sl.registerLazySingleton(() => GetSeasonDetailsUseCase(sl()));
    sl.registerLazySingleton(() => GetAllPopularTVShowsUseCase(sl()));
    sl.registerLazySingleton(() => GetAllTopRatedTVShowsUseCase(sl()));
    sl.registerLazySingleton(() => SearchUseCase(sl()));
    sl.registerLazySingleton(() => GetWatchlistItemsUseCase(sl()));
    sl.registerLazySingleton(() => AddWatchlistItemUseCase(sl()));
    sl.registerLazySingleton(() => RemoveWatchlistItemUseCase(sl()));
    sl.registerLazySingleton(() => CheckIfItemAddedUseCase(sl()));
    sl.registerLazySingleton(() => GetCinemasUseCase(sl()));

    // Bloc
    sl.registerFactory(() => MoviesBloc(sl()));
    sl.registerFactory(() => MovieDetailsBloc(sl()));
    sl.registerFactory(() => PopularMoviesBloc(sl()));
    sl.registerFactory(() => TopRatedMoviesBloc(sl()));
    sl.registerFactory(() => TVShowsBloc(sl()));
    sl.registerFactory(() => TVShowDetailsBloc(sl(), sl()));
    sl.registerFactory(() => PopularTVShowsBloc(sl()));
    sl.registerFactory(() => TopRatedTVShowsBloc(sl()));
    sl.registerFactory(() => CinemasBloc(sl()));
    sl.registerFactory(() => WatchlistBloc(sl(), sl(), sl(), sl()));
    sl.registerFactory(() => RecommendationBloc(sl(), sl(), sl()));
    sl.registerFactory(() => SearchBloc(sl()));

    // Services
    // Weather API Key - OpenWeatherMap (ENV with fallback)
    const envWeatherApiKey = String.fromEnvironment('WEATHER_API_KEY', defaultValue: '');
    const fallbackWeatherApiKey = 'bd5e378503939ddaee76f12ad7a97608';
    final weatherApiKey = envWeatherApiKey.isEmpty ? fallbackWeatherApiKey : envWeatherApiKey;

    if (kDebugMode) {
      print('[ServiceLocator] Weather API Key configured: YES');
    }
    sl.registerLazySingleton<WeatherService>(() => WeatherService(apiKey: weatherApiKey, client: http.Client()));
    sl.registerLazySingleton<TicketService>(() => TicketService());
    sl.registerLazySingleton<ProfileService>(() => ProfileService());
    sl.registerLazySingleton<AuthService>(() => AuthService());
    sl.registerLazySingleton<LocalCredentialService>(() => LocalCredentialService());
    sl.registerLazySingleton<LocalAdminService>(() => LocalAdminService());
    // AuthStateNotifier listens to auth changes and notifies GoRouter to refresh redirects
    sl.registerLazySingleton<AuthStateNotifier>(() => AuthStateNotifier(sl<AuthService>()));
    sl.registerLazySingleton(() => FirebaseWatchlistSyncService(userIdProvider: () => sl<AuthService>().currentUser?.uid));
    // F&B order service
    sl.registerLazySingleton<FnbOrderService>(() => FnbOrderService());
    // Reward service (local points, vouchers, member card)
    sl.registerLazySingleton<RewardService>(() => RewardService());
  }
}
