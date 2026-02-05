// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movies_app/core/resources/app_routes.dart';

/// Lightweight AppPopScope wrapper used across the app.
/// It provides a consistent back button behavior:
/// - if [canPop] is true, normal pop is allowed when the router has a back stack;
/// - otherwise (or when router cannot pop) it navigates to [AppRoutes.moviesRoute]
///   instead of popping the last page off the stack (prevents black screens).
class AppPopScope extends StatelessWidget {
  final bool canPop;
  final Widget child;

  const AppPopScope({Key? key, this.canPop = true, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final router = GoRouter.of(context);
        // If allowed to pop and router has a back stack, allow the pop
        if (canPop && router.canPop()) return true;
        // Otherwise navigate to home (movies) to avoid popping the last page
        router.goNamed(AppRoutes.moviesRoute);
        return false;
      },
      child: child,
    );
  }
}
