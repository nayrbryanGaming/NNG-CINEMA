# NNG-CINEMA

A Flutter-based cinema application with intelligent weather-based movie recommendations, real-time search functionality, and comprehensive media management. Features include weather integration, movie discovery, and personalized recommendations powered by TMDB API.

---

## Overview

NNG-CINEMA is an enterprise-grade mobile application that redefines the movie discovery experience through intelligent, context-aware recommendations. The application leverages real-time weather data to curate personalized movie suggestions, creating a seamless connection between environmental conditions and viewing preferences.

Built with scalability and maintainability as core principles, the application implements Clean Architecture patterns with domain-driven design, ensuring robust separation of concerns and testability across all layers.

---

## Core Features

### Intelligent Recommendation Engine
- Weather-based movie curation algorithm that analyzes real-time meteorological data
- Dynamic content adaptation based on temperature, precipitation, and atmospheric conditions
- Personalized suggestion pipeline with user preference learning capabilities

### Content Discovery Platform
- Comprehensive movie catalog integration via TMDB API
- Real-time search with intelligent query parsing and result ranking
- Multi-category browsing: Now Playing, Popular, Top Rated, and Upcoming releases
- TV Series support with season and episode management

### User Experience
- Watchlist management with cloud synchronization
- Secure authentication via Firebase Auth with Google Sign-In integration
- Profile customization and preference management
- Ticket booking simulation with QR code generation
- Food and beverage ordering system

### Media Management
- High-performance image caching and lazy loading
- Video trailer integration with YouTube player
- Comprehensive movie details including cast, crew, reviews, and similar titles

---

## Technical Architecture

### Technology Stack

| Layer | Technology |
|-------|------------|
| Frontend | Flutter 3.x, Dart |
| State Management | BLoC Pattern |
| Backend Services | Firebase (Auth, Firestore, Storage, Crashlytics) |
| API Integration | TMDB API, OpenWeatherMap API |
| Navigation | GoRouter |
| Dependency Injection | GetIt |
| HTTP Client | Dio |
| Local Storage | Hive |

### Architecture Pattern

The application follows Clean Architecture principles with clear separation:

```
lib/
├── core/                    # Shared utilities, services, entities
│   ├── data/               # Data sources, repositories implementation
│   ├── domain/             # Business logic, use cases, entities
│   ├── presentation/       # Shared UI components
│   └── services/           # Application services
├── movies/                  # Movies feature module
├── tv_shows/               # TV Shows feature module
├── search/                 # Search feature module
├── recommendations/        # Weather-based recommendations
├── auth/                   # Authentication module
└── profile/                # User profile management
```

### Design Principles
- SOLID principles implementation
- Repository pattern for data abstraction
- Use case driven business logic
- Reactive state management with BLoC
- Functional programming concepts with Dartz

---

## Prerequisites

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android SDK (API Level 21+)
- Xcode 14+ (for iOS development)
- Firebase project configuration
- TMDB API access
- OpenWeatherMap API access

---

## Installation

### 1. Clone Repository

```bash
git clone https://github.com/nayrbryanGaming/NNG-CINEMA.git
cd NNG-CINEMA
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Environment Configuration

Copy the environment template and configure your API keys:

```bash
cp .env.example .env
```

Edit `.env` with your credentials:

```env
TMDB_API_KEY=your_tmdb_api_key
WEATHER_API_KEY=your_openweathermap_api_key
FIREBASE_API_KEY=your_firebase_api_key
FIREBASE_APP_ID=your_firebase_app_id
FIREBASE_MESSAGING_SENDER_ID=your_messaging_sender_id
FIREBASE_PROJECT_ID=your_firebase_project_id
FIREBASE_STORAGE_BUCKET=your_firebase_storage_bucket
```

### 4. Firebase Setup

Configure Firebase for your project:

```bash
flutterfire configure
```

Ensure `google-services.json` is placed in `android/app/` directory.

### 5. Run Application

Development mode with environment variables:

```bash
flutter run \
  --dart-define=TMDB_API_KEY=your_key \
  --dart-define=WEATHER_API_KEY=your_key \
  --dart-define=FIREBASE_API_KEY=your_key \
  --dart-define=FIREBASE_APP_ID=your_app_id \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=your_sender_id \
  --dart-define=FIREBASE_PROJECT_ID=your_project_id \
  --dart-define=FIREBASE_STORAGE_BUCKET=your_bucket
```

### 6. Build Release

```bash
flutter build apk --release \
  --dart-define=TMDB_API_KEY=your_key \
  --dart-define=WEATHER_API_KEY=your_key \
  --dart-define=FIREBASE_API_KEY=your_key \
  --dart-define=FIREBASE_APP_ID=your_app_id \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=your_sender_id \
  --dart-define=FIREBASE_PROJECT_ID=your_project_id \
  --dart-define=FIREBASE_STORAGE_BUCKET=your_bucket
```

---

## Weather Recommendation Algorithm

The recommendation engine maps weather conditions to movie categories:

| Condition | Temperature | Recommendation Strategy |
|-----------|-------------|------------------------|
| Rain/Thunderstorm | Any | Feel-good films, Top-rated classics |
| Cold | < 18C | Cozy atmosphere movies, Drama, Romance |
| Hot | >= 30C | Light entertainment, Action, Comedy |
| Clear | Any | Popular releases, Adventure, Sci-Fi |
| Cloudy | Any | Recently released titles, Mystery, Thriller |

---

## Security Configuration

### API Key Management
- All API keys are loaded via compile-time environment variables
- No hardcoded credentials in source code
- `.gitignore` configured to exclude sensitive files

### Firebase Security Rules
- Firestore rules enforce user-level data isolation
- Storage rules restrict access to authenticated users
- Authentication state managed securely via Firebase Auth

### Recommended Practices
- Rotate API keys periodically
- Use Firebase App Check for production
- Implement rate limiting on backend services
- Enable Firebase Security Rules in production mode

---

## Project Structure

```
NNG-CINEMA/
├── android/                 # Android platform configuration
├── ios/                     # iOS platform configuration
├── lib/                     # Dart source code
│   ├── core/               # Core modules and shared code
│   ├── movies/             # Movies feature
│   ├── tv_shows/           # TV Shows feature
│   ├── search/             # Search functionality
│   ├── recommendations/    # Weather recommendations
│   ├── auth/               # Authentication
│   ├── profile/            # User profile
│   └── main.dart           # Application entry point
├── assets/                  # Static assets (images, fonts)
├── test/                    # Unit and widget tests
├── .env.example            # Environment variables template
└── pubspec.yaml            # Package configuration
```

---

## Testing

Run unit tests:

```bash
flutter test
```

Run with coverage:

```bash
flutter test --coverage
```

---

## API Documentation

### TMDB API
- Documentation: https://developer.themoviedb.org/docs
- API Key Registration: https://www.themoviedb.org/settings/api

### OpenWeatherMap API
- Documentation: https://openweathermap.org/api
- API Key Registration: https://openweathermap.org/appid

### Firebase
- Documentation: https://firebase.google.com/docs
- Console: https://console.firebase.google.com

---

## Contributing

Contributions are welcome. Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/enhancement`)
3. Commit changes with conventional commit messages
4. Push to the branch (`git push origin feature/enhancement`)
5. Open a Pull Request with detailed description

### Code Standards
- Follow Dart style guide and effective Dart practices
- Maintain test coverage for new features
- Document public APIs
- Run `flutter analyze` before committing

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## Author

**Nayr Bryan Gaming**

- GitHub: [@nayrbryanGaming](https://github.com/nayrbryanGaming)

---

## Acknowledgments

- [The Movie Database (TMDB)](https://www.themoviedb.org) for comprehensive movie data
- [OpenWeatherMap](https://openweathermap.org) for weather API services
- [Firebase](https://firebase.google.com) for backend infrastructure
- Flutter and Dart teams for the exceptional framework

---

Version 1.0.0 | Last Updated: February 2026

