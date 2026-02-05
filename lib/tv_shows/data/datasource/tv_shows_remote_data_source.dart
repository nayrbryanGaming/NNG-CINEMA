import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:movies_app/core/data/error/exceptions.dart';
import 'package:movies_app/core/data/network/api_constants.dart';
import 'package:movies_app/core/data/network/error_message_model.dart';
import 'package:movies_app/tv_shows/data/models/season_details_model.dart';
import 'package:movies_app/tv_shows/data/models/tv_show_details_model.dart';
import 'package:movies_app/tv_shows/data/models/tv_show_model.dart';
import 'package:movies_app/tv_shows/domain/usecases/get_season_details_usecase.dart';

// Top-level function for isolate computation
List<TVShowModel> _parseTVShowList(List<dynamic> jsonList) {
  return List<TVShowModel>.from(jsonList.map((e) => TVShowModel.fromJson(e)));
}

abstract class TVShowsRemoteDataSource {
  Future<List<TVShowModel>> getOnAirTVShows();
  Future<List<TVShowModel>> getPopularTVShows();
  Future<List<TVShowModel>> getTopRatedTVShows();
  Future<List<List<TVShowModel>>> getTVShows();
  Future<TVShowDetailsModel> getTVShowDetails(int id);
  Future<SeasonDetailsModel> getSeasonDetails(SeasonDetailsParams params);
  Future<List<TVShowModel>> getAllPopularTVShows(int page);
  Future<List<TVShowModel>> getAllTopRatedTVShows(int page);
}

class TVShowsRemoteDataSourceImpl extends TVShowsRemoteDataSource {
  // Create a singleton Dio instance with sensible defaults and logging
  static final Dio _dio = Dio()
    ..options.connectTimeout = const Duration(seconds: 40)
    ..options.receiveTimeout = const Duration(seconds: 40)
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
            print('🌐 DIAGNOSIS: Cek koneksi / DNS emulator.');
          } else if (error.type == DioExceptionType.connectionTimeout) {
            print('⏰ DIAGNOSIS: Timeout koneksi TV Shows endpoint.');
          }
          print('❌ ERROR: ${error.response?.statusCode} ${error.requestOptions.uri}');
          print('❌ ERROR MESSAGE: $msg');
        }
        handler.next(error);
      },
    ));

  Future<Response> _safeGet(String url) async {
    int attempt = 0;
    DioException? lastErr;
    while (attempt < 3) {
      try {
        return await _dio.get(url);
      } on DioException catch (e) {
        lastErr = e;
        final msg = e.message ?? '';
        if (msg.contains('Failed host lookup')) {
          await Future.delayed(Duration(seconds: 2 + attempt));
        } else if (e.type == DioExceptionType.connectionTimeout) {
          await Future.delayed(Duration(seconds: 2 * (attempt + 1)));
        } else {
          break;
        }
        attempt++;
      }
    }
    throw lastErr ?? DioException(requestOptions: RequestOptions(path: url));
  }

  @override
  Future<List<TVShowModel>> getOnAirTVShows() async {
    final response = await _safeGet(ApiConstants.onAirTvShowsPath);
    if (response.statusCode == 200) {
      return await compute(_parseTVShowList, response.data['results'] as List);
    } else {
      throw ServerException(
        errorMessageModel: ErrorMessageModel.fromJson(response.data),
      );
    }
  }

  @override
  Future<List<TVShowModel>> getPopularTVShows() async {
    final response = await _safeGet(ApiConstants.popularTvShowsPath);
    if (response.statusCode == 200) {
      return await compute(_parseTVShowList, response.data['results'] as List);
    } else {
      throw ServerException(
        errorMessageModel: ErrorMessageModel.fromJson(response.data),
      );
    }
  }

  @override
  Future<List<TVShowModel>> getTopRatedTVShows() async {
    final response = await _safeGet(ApiConstants.topRatedTvShowsPath);
    if (response.statusCode == 200) {
      return await compute(_parseTVShowList, response.data['results'] as List);
    } else {
      throw ServerException(
        errorMessageModel: ErrorMessageModel.fromJson(response.data),
      );
    }
  }

  @override
  Future<List<List<TVShowModel>>> getTVShows() async {
    return Future.wait([
      getOnAirTVShows(),
      getPopularTVShows(),
      getTopRatedTVShows(),
    ], eagerError: true);
  }

  @override
  Future<TVShowDetailsModel> getTVShowDetails(int id) async {
    final response = await _safeGet(ApiConstants.getTvShowDetailsPath(id));
    if (response.statusCode == 200) {
      return TVShowDetailsModel.fromJson(response.data);
    } else {
      throw ServerException(
        errorMessageModel: ErrorMessageModel.fromJson(response.data),
      );
    }
  }

  @override
  Future<SeasonDetailsModel> getSeasonDetails(SeasonDetailsParams params) async {
    final response = await _safeGet(ApiConstants.getSeasonDetailsPath(params));
    if (response.statusCode == 200) {
      return SeasonDetailsModel.fromJson(response.data);
    } else {
      throw ServerException(
        errorMessageModel: ErrorMessageModel.fromJson(response.data),
      );
    }
  }

  @override
  Future<List<TVShowModel>> getAllPopularTVShows(int page) async {
    final response = await _safeGet(ApiConstants.getAllPopularTvShowsPath(page));
    if (response.statusCode == 200) {
      return List<TVShowModel>.from((response.data['results'] as List).map((e) => TVShowModel.fromJson(e)));
    } else {
      throw ServerException(
        errorMessageModel: ErrorMessageModel.fromJson(response.data),
      );
    }
  }

  @override
  Future<List<TVShowModel>> getAllTopRatedTVShows(int page) async {
    final response = await _safeGet(ApiConstants.getAllTopRatedTvShowsPath(page));
    if (response.statusCode == 200) {
      return List<TVShowModel>.from((response.data['results'] as List).map((e) => TVShowModel.fromJson(e)));
    } else {
      throw ServerException(
        errorMessageModel: ErrorMessageModel.fromJson(response.data),
      );
    }
  }
}
