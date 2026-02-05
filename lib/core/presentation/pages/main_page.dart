import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movies_app/core/presentation/pages/pop_scope.dart';

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
      backgroundColor: const Color(0xFF141414), // Force dark background
      body: AppPopScope(canPop: true, child: widget.child),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            label: 'Home',
            icon: Icon(
              Icons.home_outlined,
              size: AppSize.s22,
            ),
            activeIcon: Icon(
              Icons.home,
              size: AppSize.s22,
            ),
          ),
          BottomNavigationBarItem(
            label: 'Bioskop',
            icon: Icon(
              Icons.theaters_outlined,
              size: AppSize.s22,
            ),
            activeIcon: Icon(
              Icons.theaters,
              size: AppSize.s22,
            ),
          ),
          BottomNavigationBarItem(
            label: 'F&B',
            icon: Icon(
              Icons.fastfood_outlined,
              size: AppSize.s22,
            ),
            activeIcon: Icon(
              Icons.fastfood,
              size: AppSize.s22,
            ),
          ),
          BottomNavigationBarItem(
            label: 'My NNG',
            icon: Icon(
              Icons.person_outline,
              size: AppSize.s22,
            ),
            activeIcon: Icon(
              Icons.person,
              size: AppSize.s22,
            ),
          ),
          BottomNavigationBarItem(
            label: 'Menu',
            icon: Icon(
              Icons.menu,
              size: AppSize.s22,
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
    if (location.startsWith(AppRoutes.moviesPath)) return 0;
    // Treat both Cinemas (bioskop) and Tickets as the same section (index 1)
    if (location.startsWith(AppRoutes.cinemasPath) || location.startsWith(AppRoutes.myTicketsPath)) return 1;
    // F&B section includes both fnb menu and fnb orders
    if (location.startsWith(AppRoutes.fnbPath) || location.startsWith(AppRoutes.fnbOrdersPath)) return 2;
    if (location.startsWith(AppRoutes.profilePath)) return 3; // My NNG -> Profile
    if (location.startsWith(AppRoutes.menuPath)) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.goNamed(AppRoutes.moviesRoute);
        break;
      case 1:
        // Navigate to Cinemas (bioskop) section; Tickets is accessible inside that flow
        context.goNamed(AppRoutes.cinemasRoute);
        break;
      case 2:
        context.goNamed(AppRoutes.fnbRoute);
        break;
      case 3:
        // My NNG intentionally goes to profile page (My NNG = profile)
        context.goNamed(AppRoutes.profileRoute);
        break;
      case 4:
        context.goNamed(AppRoutes.menuRoute);
        break;
    }
  }
}
