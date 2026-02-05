import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'admin_gate.dart';
import 'admin_shell_page.dart';
import 'dashboard/admin_dashboard_page.dart';
import 'movies/movies_list_page.dart';
import 'movies/movie_form_page.dart';
import 'cinemas/cinemas_list_page.dart';
import 'schedules/schedules_list_page.dart';
import 'orders/orders_list_page.dart';
import 'users/users_list_page.dart';
import 'audit/audit_log_page.dart';
import 'analytics/analytics_dashboard_page.dart';
import 'presentation/views/admin_data_list_page.dart';
import 'presentation/views/admin_data_form_page.dart';
import 'presentation/views/admin_profile_page.dart';

/// Returns a top-level GoRoute for the admin section.
GoRoute getAdminRoute() {
  return GoRoute(
    path: '/admin',
    pageBuilder: (context, state) => CupertinoPage(child: AdminGate(child: AdminShellPage(child: AdminDashboardPage()))),
    routes: [
      GoRoute(
        path: 'movies',
        pageBuilder: (context, state) => CupertinoPage(child: AdminGate(child: MoviesListPage())),
      ),
      GoRoute(
        path: 'movies/new',
        pageBuilder: (context, state) => CupertinoPage(child: AdminGate(child: MovieFormPage())),
      ),
      GoRoute(
        path: 'movies/:id/edit',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return CupertinoPage(child: AdminGate(child: MovieFormPage(movieId: id)));
        },
      ),
      GoRoute(
        path: 'cinemas',
        pageBuilder: (context, state) => CupertinoPage(child: AdminGate(child: CinemasListPage())),
      ),
      GoRoute(
        path: 'schedules',
        pageBuilder: (context, state) => CupertinoPage(child: AdminGate(child: SchedulesListPage())),
      ),
      GoRoute(
        path: 'orders',
        pageBuilder: (context, state) => CupertinoPage(child: AdminGate(child: OrdersListPage())),
      ),
      GoRoute(
        path: 'users',
        pageBuilder: (context, state) => CupertinoPage(child: AdminGate(child: UsersListPage())),
      ),
      GoRoute(
        path: 'audit',
        pageBuilder: (context, state) => CupertinoPage(child: AdminGate(child: AuditLogPage())),
      ),
      GoRoute(
        path: 'data',
        pageBuilder: (context, state) => CupertinoPage(child: AdminGate(child: const AdminDataListPage())),
      ),
      GoRoute(
        path: 'data/new',
        pageBuilder: (context, state) => CupertinoPage(child: AdminGate(child: const AdminDataFormPage())),
      ),
      GoRoute(
        path: 'data/:id/edit',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'];
          return CupertinoPage(child: AdminGate(child: AdminDataFormPage(itemId: id)));
        },
      ),
      GoRoute(
        path: 'profile',
        pageBuilder: (context, state) => CupertinoPage(child: AdminGate(child: const AdminProfilePage())),
      ),
      GoRoute(
        path: 'analytics',
        pageBuilder: (context, state) => CupertinoPage(child: AdminGate(child: const AnalyticsDashboardPage())),
      ),
    ],
  );
}
