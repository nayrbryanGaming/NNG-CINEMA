import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:movies_app/core/data/error/exceptions.dart';
import 'package:movies_app/movies/data/models/movie_details_model.dart';
import 'package:movies_app/movies/data/datasource/movies_cache_service.dart';

import 'package:movies_app/core/data/network/api_constants.dart';
import 'package:movies_app/core/data/network/error_message_model.dart';
import 'package:movies_app/movies/data/models/movie_model.dart';

// Top-level functions for isolate computation
List<MovieModel> _parseMovieList(List<dynamic> jsonList) {
  return List<MovieModel>.from(jsonList.map((e) => MovieModel.fromJson(e)));
}

abstract class MoviesRemoteDataSource {
  Future<List<MovieModel>> getNowPlayingMovies();
  Future<List<MovieModel>> getPopularMovies();
  Future<List<MovieModel>> getTopRatedMovies();
  Future<List<List<MovieModel>>> getMovies();
  Future<MovieDetailsModel> getMovieDetails(int movieId);
  Future<List<MovieModel>> getAllPopularMovies(int page);
  Future<List<MovieModel>> getAllTopRatedMovies(int page);
}

class MoviesRemoteDataSourceImpl extends MoviesRemoteDataSource {
  // Cache service untuk menyimpan data film
  final MoviesCacheService _cacheService = MoviesCacheService();

  // Create a singleton Dio instance with sensible defaults and logging
  static final Dio _dio = Dio()
    ..options.connectTimeout = const Duration(seconds: 20)
    ..options.receiveTimeout = const Duration(seconds: 20)
    ..interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (kDebugMode) {
          print('🔵 REQUEST: ${options.method} ${options.uri}');
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          print('✅ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
        }
        handler.next(response);
      },
      onError: (error, handler) {
        if (kDebugMode) {
          final msg = error.message ?? '';
          if (msg.contains('Failed host lookup')) {
            print('🌐 DIAGNOSIS: Periksa koneksi internet emulator/host. Buka browser emulator ke https://api.themoviedb.org untuk uji DNS.');
          } else if (error.type == DioExceptionType.connectionTimeout) {
            print('⏰ DIAGNOSIS: Timeout koneksi. Mungkin jaringan lambat / diblok firewall / VPN.');
          }
          print('❌ ERROR: ${error.response?.statusCode} ${error.requestOptions.uri}');
          print('❌ ERROR MESSAGE: $msg');
        }
        handler.next(error);
      },
    ));

  // Unified GET with retry + exponential backoff
  Future<Response> _safeGet(String url) async {
    int attempt = 0;
    DioException? lastErr;
    while (attempt < 3) {
      try {
        final resp = await _dio.get(url);
        return resp;
      } on DioException catch (e) {
        lastErr = e;
        final msg = e.message ?? '';
        if (msg.contains('Failed host lookup')) {
          // No point retrying immediately if DNS fails; small backoff.
          await Future.delayed(Duration(seconds: 2 + attempt));
        } else if (e.type == DioExceptionType.connectionTimeout) {
          await Future.delayed(Duration(seconds: 2 * (attempt + 1)));
        } else {
          // For other errors (e.g., 4xx/5xx) break early
          break;
        }
        attempt++;
      }
    }
    throw lastErr ?? DioException(requestOptions: RequestOptions(path: url));
  }

  @override
  Future<List<MovieModel>> getNowPlayingMovies() async {
    // Try cache first
    final cached = await _cacheService.getNowPlayingMovies();
    if (cached != null) return cached;

    // Fetch from network
    final response = await _safeGet(ApiConstants.nowPlayingMoviesPath);
    if (response.statusCode == 200) {
      final movies = await compute(_parseMovieList, response.data['results'] as List);
      // Save to cache
      await _cacheService.saveNowPlayingMovies(movies);
      return movies;
    } else {
      throw ServerException(
        errorMessageModel: ErrorMessageModel.fromJson(response.data),
      );
    }
  }

  @override
  Future<List<MovieModel>> getPopularMovies() async {
    // Try cache first
    final cached = await _cacheService.getPopularMovies();
    if (cached != null) return cached;

    // Fetch from network
    final response = await _safeGet(ApiConstants.popularMoviesPath);
    if (response.statusCode == 200) {
      final movies = await compute(_parseMovieList, response.data['results'] as List);
      // Save to cache
      await _cacheService.savePopularMovies(movies);
      return movies;
    } else {
      throw ServerException(
        errorMessageModel: ErrorMessageModel.fromJson(response.data),
      );
    }
  }

  @override
  Future<List<MovieModel>> getTopRatedMovies() async {
    // Try cache first
    final cached = await _cacheService.getTopRatedMovies();
    if (cached != null) return cached;

    // Fetch from network
    final response = await _safeGet(ApiConstants.topRatedMoviesPath);
    if (response.statusCode == 200) {
      final movies = await compute(_parseMovieList, response.data['results'] as List);
      // Save to cache
      await _cacheService.saveTopRatedMovies(movies);
      return movies;
    } else {
      throw ServerException(
        errorMessageModel: ErrorMessageModel.fromJson(response.data),
      );
    }
  }

  @override
  Future<List<List<MovieModel>>> getMovies() async {
    final response = Future.wait([
      getNowPlayingMovies(),
      getPopularMovies(),
      getTopRatedMovies(),
    ], eagerError: true);
    return response;
  }

  @override
  Future<MovieDetailsModel> getMovieDetails(int movieId) async {
    final response = await _safeGet(ApiConstants.getMovieDetailsPath(movieId));
    if (response.statusCode == 200) {
      return MovieDetailsModel.fromJson(response.data);
    } else {
      throw ServerException(
        errorMessageModel: ErrorMessageModel.fromJson(response.data),
      );
    }
  }

  @override
  Future<List<MovieModel>> getAllPopularMovies(int page) async {
    final response = await _safeGet(ApiConstants.getAllPopularMoviesPath(page));
    if (response.statusCode == 200) {
      return await compute(_parseMovieList, response.data['results'] as List);
    } else {
      throw ServerException(
        errorMessageModel: ErrorMessageModel.fromJson(response.data),
      );
    }
  }

  @override
  Future<List<MovieModel>> getAllTopRatedMovies(int page) async {
    final response = await _safeGet(ApiConstants.getAllTopRatedMoviesPath(page));
    if (response.statusCode == 200) {
      return await compute(_parseMovieList, response.data['results'] as List);
    } else {
      throw ServerException(
        errorMessageModel: ErrorMessageModel.fromJson(response.data),
      );
    }
  }
}
