import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:movies_app/core/services/weather_service.dart';
import 'package:geolocator/geolocator.dart';

class TestWeatherService extends WeatherService {
  final Position? forcedPosition;
  TestWeatherService({required String apiKey, http.Client? client, this.forcedPosition}) : super(apiKey: apiKey, client: client);

  @override
  Future<Position?> getPositionWithFallback() async {
    return forcedPosition;
  }
}

void main() {
  group('WeatherService', () {
    test('parses weather info from successful response', () async {
      final sample = {
        'weather': [
          {'main': 'Clear', 'description': 'clear sky'}
        ],
        'main': {'temp': 300.15}
      };

      final client = MockClient((request) async {
        return http.Response(jsonEncode(sample), 200);
      });

      final pos = Position(
        latitude: -6.2,
        longitude: 106.8,
        timestamp: DateTime.now(),
        accuracy: 10,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        headingAccuracy: 0,
        altitudeAccuracy: 0,
      );

      final svc = TestWeatherService(apiKey: 'abc', client: client, forcedPosition: pos);
      final info = await svc.getWeatherInfo();
      expect(info.main, 'Clear');
      expect(info.description, 'clear sky');
      expect(info.temperatureCelsius, closeTo(27.0, 0.5));
    });

    test('retries on failure then succeeds', () async {
      int calls = 0;
      final sample = {
        'weather': [
          {'main': 'Clouds', 'description': 'few clouds'}
        ],
        'main': {'temp': 290.15}
      };
      final client = MockClient((request) async {
        calls++;
        if (calls < 3) return http.Response('error', 500);
        return http.Response(jsonEncode(sample), 200);
      });

      final pos = Position(
        latitude: -6.2,
        longitude: 106.8,
        timestamp: DateTime.now(),
        accuracy: 10,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        headingAccuracy: 0,
        altitudeAccuracy: 0,
      );

      final svc = TestWeatherService(apiKey: 'abc', client: client, forcedPosition: pos);
      final info = await svc.getWeatherInfo();
      expect(calls >= 3, true);
      expect(info.main, 'Clouds');
      expect(info.temperatureCelsius, closeTo(17.0, 0.5));
    });
  });
}
