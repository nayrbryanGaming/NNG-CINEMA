import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:movies_app/cinemas/domain/entities/cinema.dart';
import 'package:movies_app/cinemas/domain/entities/movie_showtime.dart';
import 'package:movies_app/cinemas/domain/entities/seat.dart';
import 'package:movies_app/cinemas/domain/entities/seat_status.dart';
import 'package:movies_app/cinemas/domain/entities/ticket_order.dart';
import 'package:movies_app/profile/domain/entities/user_profile.dart';

import 'package:movies_app/core/domain/entities/media.dart';
import 'package:movies_app/core/resources/app_router.dart';
import 'package:movies_app/core/resources/app_strings.dart';
import 'package:movies_app/core/resources/app_theme.dart';
import 'package:movies_app/core/services/service_locator.dart';
import 'package:movies_app/watchlist/presentation/controllers/watchlist_bloc/watchlist_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive in a subdirectory to avoid cloud sync conflicts
  await Hive.initFlutter('database');

  // Register all Hive adapters
  Hive.registerAdapter(MediaAdapter());
  Hive.registerAdapter(SeatStatusAdapter());
  Hive.registerAdapter(SeatAdapter());
  Hive.registerAdapter(MovieShowtimeAdapter());
  Hive.registerAdapter(CinemaAdapter());
  Hive.registerAdapter(TicketOrderAdapter());
  Hive.registerAdapter(UserProfileAdapter());

  // Open Hive boxes
  await Hive.openBox('items'); // For watchlist
  await Hive.openBox<TicketOrder>('tickets'); // For tickets
  await Hive.openBox<UserProfile>('profile'); // For profile

  // Initialize dependency injection
  ServiceLocator.init();

  // Run the app with a global BlocProvider
  runApp(
    BlocProvider(
      create: (context) => sl<WatchlistBloc>(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: getApplicationTheme(),
      routerConfig: AppRouter.router, // GoRouter config
    );
  }
}
