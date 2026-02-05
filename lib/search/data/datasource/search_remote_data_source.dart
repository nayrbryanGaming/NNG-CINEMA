import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:movies_app/core/data/error/exceptions.dart';
import 'package:movies_app/core/data/network/api_constants.dart';
import 'package:movies_app/core/data/network/error_message_model.dart';
import 'package:movies_app/search/data/models/search_result_item_model.dart';

// Top-level function for isolate computation
List<SearchResultItemModel> _parseSearchResults(List<dynamic> jsonList) {
  return List<SearchResultItemModel>.from(
    jsonList
        .where((e) => e['media_type'] != 'person')
        .map((e) => SearchResultItemModel.fromJson(e))
  );
}

abstract class SearchRemoteDataSource {
  Future<List<SearchResultItemModel>> search(String title);
}

class SearchRemoteDataSourceImpl extends SearchRemoteDataSource {
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
            print('🌐 DIAGNOSIS: DNS gagal. Cek koneksi emulator.');
          } else if (error.type == DioExceptionType.connectionTimeout) {
            print('⏰ DIAGNOSIS: Timeout pencarian TMDB.');
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
  Future<List<SearchResultItemModel>> search(String title) async {
    final response = await _safeGet(ApiConstants.getSearchPath(title));
    if (response.statusCode == 200) {
      return await compute(_parseSearchResults, response.data['results'] as List);
    } else {
      throw ServerException(
        errorMessageModel: ErrorMessageModel.fromJson(response.data),
      );
    }
  }
}
