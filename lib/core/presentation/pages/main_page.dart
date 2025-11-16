import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movies_app/core/resources/app_router.dart';
import 'package:movies_app/core/resources/app_strings.dart';

import 'package:movies_app/core/resources/app_routes.dart';
import 'package:movies_app/core/resources/app_values.dart';

class MainPage extends StatefulWidget {
  const MainPage({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          final String location = GoRouterState.of(context).uri.toString();
          if (!location.startsWith(moviesPath)) {
            _onItemTapped(0, context);
          }
          return true;
        },
        child: widget.child,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            label: AppStrings.movies,
            icon: Icon(
              Icons.movie_creation_rounded,
              size: AppSize.s20,
            ),
          ),
          BottomNavigationBarItem(
            label: AppStrings.shows,
            icon: Icon(
              Icons.tv_rounded,
              size: AppSize.s20,
            ),
          ),
          BottomNavigationBarItem(
            label: AppStrings.cinemas,
            icon: Icon(
              Icons.theaters_rounded,
              size: AppSize.s20,
            ),
          ),
          BottomNavigationBarItem(
            label: AppStrings.recommendations, // Changed from search
            icon: Icon(
              Icons.star_rounded, // Changed from search
              size: AppSize.s20,
            ),
          ),
          BottomNavigationBarItem(
            label: AppStrings.profile,
            icon: Icon(
              Icons.person_rounded,
              size: AppSize.s20,
            ),
          ),
        ],
        currentIndex: _getSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
      ),
    );
  }

  int _getSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(moviesPath)) {
      return 0;
    }
    if (location.startsWith(tvShowsPath)) {
      return 1;
    }
    if (location.startsWith(cinemasPath)) {
      return 2;
    }
    if (location.startsWith(recommendationsPath)) { // Changed from search
      return 3;
    }
    if (location.startsWith(profilePath)) {
      return 4;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.goNamed(AppRoutes.moviesRoute);
        break;
      case 1:
        context.goNamed(AppRoutes.tvShowsRoute);
        break;
      case 2:
        context.goNamed(AppRoutes.cinemasRoute);
        break;
      case 3:
        context.goNamed(AppRoutes.recommendationsRoute); // Changed from search
        break;
      case 4:
        context.goNamed(AppRoutes.profileRoute);
        break;
    }
  }
}
