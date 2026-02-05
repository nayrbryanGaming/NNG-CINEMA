import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:movies_app/movies/data/models/movie_model.dart';

/// Service untuk cache data film menggunakan Hive
/// Cache akan menyimpan data film selama waktu tertentu untuk mengurangi
/// ketergantungan pada jaringan setiap kali kembali ke home
class MoviesCacheService {
  static const String _boxName = 'movies_cache';
  static const String _nowPlayingKey = 'now_playing';
  static const String _popularKey = 'popular';
  static const String _topRatedKey = 'top_rated';
  static const String _timestampSuffix = '_timestamp';

  // Cache duration: 30 menit
  static const Duration cacheDuration = Duration(minutes: 30);

  Box? _box;

  Future<Box> _getBox() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox(_boxName);
    }
    return _box!;
  }

  /// Check if cache is still valid
  bool _isCacheValid(int? timestamp) {
    if (timestamp == null) return false;
    final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    return now.difference(cacheTime) < cacheDuration;
  }

  /// Save movies to cache
  Future<void> saveMovies(String key, List<MovieModel> movies) async {
    try {
      final box = await _getBox();
      final jsonList = movies.map((m) => m.toJson()).toList();
      await box.put(key, jsonEncode(jsonList));
      await box.put('$key$_timestampSuffix', DateTime.now().millisecondsSinceEpoch);
      if (kDebugMode) print('💾 Cache saved: $key (${movies.length} items)');
    } catch (e) {
      if (kDebugMode) print('❌ Cache save error: $e');
    }
  }

  /// Get movies from cache
  Future<List<MovieModel>?> getMovies(String key) async {
    try {
      final box = await _getBox();
      final timestamp = box.get('$key$_timestampSuffix') as int?;

      if (!_isCacheValid(timestamp)) {
        if (kDebugMode) print('⏰ Cache expired or not found: $key');
        return null;
      }

      final jsonString = box.get(key) as String?;
      if (jsonString == null) return null;

      final jsonList = jsonDecode(jsonString) as List;
      final movies = jsonList.map((e) => MovieModel.fromJson(e as Map<String, dynamic>)).toList();
      if (kDebugMode) print('✅ Cache hit: $key (${movies.length} items)');
      return movies;
    } catch (e) {
      if (kDebugMode) print('❌ Cache read error: $e');
      return null;
    }
  }

  /// Get now playing movies from cache
  Future<List<MovieModel>?> getNowPlayingMovies() => getMovies(_nowPlayingKey);

  /// Save now playing movies to cache
  Future<void> saveNowPlayingMovies(List<MovieModel> movies) => saveMovies(_nowPlayingKey, movies);

  /// Get popular movies from cache
  Future<List<MovieModel>?> getPopularMovies() => getMovies(_popularKey);

  /// Save popular movies to cache
  Future<void> savePopularMovies(List<MovieModel> movies) => saveMovies(_popularKey, movies);

  /// Get top rated movies from cache
  Future<List<MovieModel>?> getTopRatedMovies() => getMovies(_topRatedKey);

  /// Save top rated movies to cache
  Future<void> saveTopRatedMovies(List<MovieModel> movies) => saveMovies(_topRatedKey, movies);

  /// Clear all cache
  Future<void> clearCache() async {
    try {
      final box = await _getBox();
      await box.clear();
      if (kDebugMode) print('🗑️ Cache cleared');
    } catch (e) {
      if (kDebugMode) print('❌ Cache clear error: $e');
    }
  }

  /// Check if we have valid cache for all movie categories
  Future<bool> hasValidCache() async {
    final nowPlaying = await getNowPlayingMovies();
    final popular = await getPopularMovies();
    final topRated = await getTopRatedMovies();
    return nowPlaying != null && popular != null && topRated != null;
  }
}

