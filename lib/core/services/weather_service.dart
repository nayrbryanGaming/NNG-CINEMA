import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:movies_app/core/domain/entities/weather_info.dart';

// Helper class to pass multiple parameters to compute()
class _WeatherApiParams {
  final double latitude;
  final double longitude;
  final String apiKey;

  _WeatherApiParams(this.latitude, this.longitude, this.apiKey);
}

// Top-level function executed in an isolate to parse weather JSON to WeatherInfo
WeatherInfo _parseWeatherResponse(String responseBody) {
  try {
    final data = json.decode(responseBody) as Map<String, dynamic>;
    final weather = (data['weather'] as List).isNotEmpty ? data['weather'][0] as Map<String, dynamic> : {};
    final main = data['main'] as Map<String, dynamic>?;
    final tempKelvin = main != null && main['temp'] != null ? (main['temp'] as num).toDouble() : null;
    final tempC = tempKelvin != null ? tempKelvin - 273.15 : null;

    return WeatherInfo(
      main: weather['main'] ?? 'Unknown',
      description: weather['description'] ?? 'Unknown',
      temperatureCelsius: tempC,
      raw: data,
    );
  } catch (e) {
    return WeatherInfo(main: 'Unknown', description: 'Unknown', temperatureCelsius: null, raw: null);
  }
}

class WeatherService {
  final String apiKey;
  final http.Client _client;

  WeatherService({required this.apiKey, http.Client? client}) : _client = client ?? http.Client();

  Position? _cachedPosition;
  DateTime? _lastFetchTime;
  WeatherInfo? _cachedWeatherInfo; // Cache weather result
  DateTime? _lastWeatherFetchTime;

  // Cache weather for 6 HOURS to minimize API calls (user can manually refresh if needed)
  static const _positionCacheDuration = Duration(hours: 6);
  static const _weatherCacheDuration = Duration(hours: 6);

  /// Public API: get detailed WeatherInfo
  /// Set [forceRefresh] to true to bypass cache (e.g., when user manually refreshes)
  Future<WeatherInfo> getWeatherInfo({Duration timeout = const Duration(seconds: 10), bool forceRefresh = false}) async {
    try {
      // Return cached weather if still valid (unless force refresh)
      if (!forceRefresh && _cachedWeatherInfo != null && _lastWeatherFetchTime != null) {
        final elapsed = DateTime.now().difference(_lastWeatherFetchTime!);
        if (elapsed < _weatherCacheDuration) {
          if (kDebugMode) print('WeatherService: Using cached weather (${elapsed.inMinutes} min old)');
          return _cachedWeatherInfo!;
        }
      }

      // Helpful guard: if apiKey is not provided we should fail fast with clear message
      if (apiKey.isEmpty) {
        if (kDebugMode) print('WeatherService: WEATHER_API_KEY is empty');
        return WeatherInfo(main: 'Unknown', description: 'No WEATHER_API_KEY configured', temperatureCelsius: null, raw: null);
      }
      final pos = await getPositionWithFallback();
      if (pos == null) return WeatherInfo(main: 'Unknown', description: 'No location', temperatureCelsius: null, raw: null);

      // Try requests with exponential backoff
      final maxAttempts = 4;
      var attempt = 0;
      while (attempt < maxAttempts) {
        try {
          final uri = Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=${pos.latitude}&lon=${pos.longitude}&appid=$apiKey');
          final resp = await _client.get(uri).timeout(timeout);
          if (resp.statusCode == 200) {
            final weatherInfo = await compute(_parseWeatherResponse, resp.body);
            // Cache the result
            _cachedWeatherInfo = weatherInfo;
            _lastWeatherFetchTime = DateTime.now();
            if (kDebugMode) print('WeatherService: Fresh weather fetched and cached');
            return weatherInfo;
          } else {
            // Try to extract message from response body if present
            if (kDebugMode) {
              try {
                final body = resp.body;
                final parsed = json.decode(body) as Map<String, dynamic>;
                final msg = parsed['message'] ?? parsed['error'] ?? body;
                print('WeatherService: non-200 response: ${resp.statusCode} - $msg');
              } catch (e) {
                print('WeatherService: non-200 response: ${resp.statusCode} - ${resp.body}');
              }
            }
            // Non-200 -> try again after backoff
          }
          // non-200 -> try again after backoff
        } catch (e) {
          if (kDebugMode) print('WeatherService request error (attempt $attempt): $e');
        }
        attempt++;
        // Exponential backoff with cap
        final backoffMs = min(3000, 500 * pow(2, attempt).toInt());
        final backoff = Duration(milliseconds: backoffMs);
        await Future.delayed(backoff);
      }

      // If API failed but we have cached data, return that instead
      if (_cachedWeatherInfo != null) {
        if (kDebugMode) print('WeatherService: API failed, returning stale cache');
        return _cachedWeatherInfo!;
      }

      return WeatherInfo(main: 'Unknown', description: 'API failure (see logs)', temperatureCelsius: null, raw: null);
    } catch (e) {
      if (kDebugMode) print('getWeatherInfo error: $e');
      // Return cached data on error if available
      if (_cachedWeatherInfo != null) return _cachedWeatherInfo!;
      return WeatherInfo(main: 'Unknown', description: 'Error', temperatureCelsius: null, raw: null);
    }
  }

  /// Backwards-compatible helper used by RecommendationBloc: returns main weather string
  Future<String> getCurrentWeather() async {
    final info = await getWeatherInfo();
    return info.main;
  }

  /// Position with caching and fallback to IP-based geolocation if GPS fails
  Future<Position?> getPositionWithFallback() async {
    // Use cached when valid
    if (_cachedPosition != null && _lastFetchTime != null) {
      final elapsed = DateTime.now().difference(_lastFetchTime!);
      if (elapsed < _positionCacheDuration) return _cachedPosition;
    }

    try {
      final pos = await _determinePosition();
      _cachedPosition = pos;
      _lastFetchTime = DateTime.now();
      return pos;
    } catch (e) {
      if (kDebugMode) print('GPS position failed: $e, trying IP-based geolocation');
      // Try IP-based geo as fallback (free IP geolocation service)
      try {
        final resp = await _client.get(Uri.parse('https://ipapi.co/json/')).timeout(const Duration(seconds: 5));
        if (resp.statusCode == 200) {
          final data = json.decode(resp.body) as Map<String, dynamic>;
          final lat = (data['latitude'] as num?)?.toDouble() ?? (data['lat'] as num?)?.toDouble();
          final lon = (data['longitude'] as num?)?.toDouble() ?? (data['lon'] as num?)?.toDouble();
          if (lat != null && lon != null) {
            final fakePos = Position(
              longitude: lon,
              latitude: lat,
              timestamp: DateTime.now(),
              accuracy: 1000,
              altitude: 0,
              heading: 0,
              speed: 0,
              speedAccuracy: 0,
              headingAccuracy: 0,
              altitudeAccuracy: 0,
            );
            _cachedPosition = fakePos;
            _lastFetchTime = DateTime.now();
            return fakePos;
          }
        }
      } catch (e) {
        if (kDebugMode) print('IP geolocation fallback failed: $e');
      }

      return null;
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Location services disabled');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) throw Exception('Location permission denied');
    }
    if (permission == LocationPermission.deniedForever) throw Exception('Location permission deniedForever');

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low, timeLimit: const Duration(seconds: 5));
  }

  void clearCache() {
    _cachedPosition = null;
    _lastFetchTime = null;
    _cachedWeatherInfo = null;
    _lastWeatherFetchTime = null;
  }
}
