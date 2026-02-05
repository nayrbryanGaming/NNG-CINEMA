Running the app with your OpenWeatherMap API key

Overview
- The app's WeatherService no longer hardcodes the API key. It reads the key provided at build/run time via a compile-time define: WEATHER_API_KEY.
- Recommendation (weather-based) is migrated to Home and runs in near-real-time:
  - Initial fetch on app start.
  - Subscribes to location changes (distanceFilter = 500m) and triggers a refresh when the device moves significantly.
  - Periodic refresh every 5 minutes.

How to provide your API key (preferred): --dart-define
- Run on an attached device or emulator (PowerShell):

```powershell
flutter run --dart-define=WEATHER_API_KEY=YOUR_OPENWEATHERMAP_KEY
```

- Build APK with the key:

```powershell
flutter build apk --release --dart-define=WEATHER_API_KEY=YOUR_OPENWEATHERMAP_KEY
```

Notes:
- Replace YOUR_OPENWEATHERMAP_KEY with your actual OpenWeatherMap API key. Do NOT commit this key to version control.
- In debug builds, the app prints a warning in the console if the key is not provided.

Alternative: local.properties (local-only)
- If you prefer not to pass --dart-define every time, you can add the key to `local.properties` (NOT committed). Add the line:

```
WEATHER_API_KEY=YOUR_OPENWEATHERMAP_KEY
```

- Then modify `ServiceLocator` to prefer reading from `local.properties` (I can add this change if you want). For now the app uses `--dart-define`.

How to test real-time behavior
1. Start the app using `flutter run --dart-define=WEATHER_API_KEY=...`.
2. On Home page, go to the Recommendations section.
3. The app will immediately fetch weather-based recommendations.
4. Move the device >500m (or simulate location changes in emulator) — the app will automatically refresh recommendations.
5. The app also refreshes every 5 minutes automatically.

If you want me to add a local-properties fallback or a secure secret-store integration (CI secrets, remote config), tell me which option you prefer and I will implement it.

Debugging
- If you see `[ServiceLocator] WARNING: WEATHER_API_KEY is empty` in the console, it means the app didn't receive the key — run with `--dart-define` as shown above.
- If weather fetch fails, RecommendationBloc will emit an error state; check logcat/console for geolocation or network errors.

Security reminder
- Never commit your API key to the repository. Use CI/CD secrets or environment variables for production builds.


