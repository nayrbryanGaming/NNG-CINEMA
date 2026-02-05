# NNG-CINEMA

A modern Flutter cinema application featuring intelligent weather-based movie recommendations, real-time search, and comprehensive entertainment management.

## Features

- Weather-based movie recommendation engine
- Real-time movie search with TMDB integration
- Now Playing, Popular, and Top Rated movies
- TV Shows browsing and details
- User authentication with Firebase and Google Sign-In
- Cloud-synced watchlist management
- Cinema ticket booking system
- Food and beverage ordering
- User profile and rewards system
- Admin dashboard

## Tech Stack

- Flutter 3.x / Dart
- Firebase (Auth, Firestore, Storage)
- BLoC State Management
- Clean Architecture
- TMDB API
- OpenWeatherMap API

## Getting Started

```bash
git clone https://github.com/nayrbryanGaming/NNG-CINEMA.git
cd NNG-CINEMA
flutter pub get
flutter run
```

## Project Structure

```
lib/
├── core/           # Shared utilities and services
├── movies/         # Movies feature
├── tv_shows/       # TV Shows feature
├── search/         # Search functionality
├── recommendations/# Weather-based recommendations
├── auth/           # Authentication
├── profile/        # User profile
├── cinemas/        # Cinema and ticketing
├── fnb/            # Food and beverage
├── watchlist/      # Watchlist management
├── admin/          # Admin dashboard
└── main.dart       # Entry point
```

## License

MIT License - see [LICENSE](LICENSE) for details.

## Author

Nayr Bryan Gaming - [@nayrbryanGaming](https://github.com/nayrbryanGaming)

