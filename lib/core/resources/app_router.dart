import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:movies_app/auth/presentation/views/login_view.dart';
import 'package:movies_app/auth/presentation/views/signup_view.dart';
import 'package:movies_app/cinemas/domain/entities/cinema.dart';
import 'package:movies_app/cinemas/domain/entities/movie_showtime.dart';
import 'package:movies_app/cinemas/domain/entities/ticket_order.dart';
import 'package:movies_app/cinemas/presentation/views/cinema_details_view.dart';
import 'package:movies_app/cinemas/presentation/views/cinemas_view.dart';
import 'package:movies_app/cinemas/presentation/views/my_tickets_view.dart';
import 'package:movies_app/cinemas/presentation/views/order_summary_view.dart';
import 'package:movies_app/cinemas/presentation/views/qris_payment_view.dart';
import 'package:movies_app/cinemas/presentation/views/seat_selection_view.dart';
import 'package:movies_app/cinemas/presentation/views/ticket_details_view.dart';
import 'package:movies_app/cinemas/presentation/views/location_selector_view.dart';
import 'package:movies_app/core/presentation/pages/main_page.dart';
import 'package:movies_app/movies/presentation/views/movie_details_view.dart';
import 'package:movies_app/movies/presentation/views/movies_view.dart';
import 'package:movies_app/profile/domain/entities/user_profile.dart';
import 'package:movies_app/profile/presentation/views/edit_profile_view.dart';
import 'package:movies_app/profile/presentation/views/menu_view.dart';
import 'package:movies_app/profile/presentation/views/profile_view.dart';
import 'package:movies_app/profile/presentation/views/promotions_view.dart';
import 'package:movies_app/profile/presentation/views/news_view.dart';
import 'package:movies_app/profile/presentation/views/facilities_view.dart';
import 'package:movies_app/profile/presentation/views/partnership_view.dart';
import 'package:movies_app/profile/presentation/views/faq_contact_view.dart';
import 'package:movies_app/profile/presentation/views/membership_view.dart';
import 'package:movies_app/profile/presentation/views/rent_view.dart';
import 'package:movies_app/profile/presentation/views/sports_hall_view.dart';
import 'package:movies_app/watchlist/presentation/views/watchlist_view.dart';
import 'package:movies_app/fnb/presentation/views/fnb_view.dart';
import 'package:movies_app/fnb/presentation/views/fnb_selection_view.dart';
import 'package:movies_app/cinemas/presentation/views/bank_transfer_payment_view.dart';
import 'package:movies_app/notifications/presentation/views/notifications_view.dart';
import 'package:movies_app/search/presentation/views/search_view.dart';
import 'package:movies_app/recommendations/presentation/views/recommendation_view.dart';
import 'package:movies_app/core/services/service_locator.dart';
import 'package:movies_app/core/services/auth_service.dart';
import 'package:movies_app/core/services/auth_state_notifier.dart';
import 'package:movies_app/admin/admin_router.dart';
import 'package:movies_app/core/resources/app_routes.dart';
import 'package:movies_app/admin/presentation/views/admin_login_view.dart';
import 'package:movies_app/core/services/local_admin_service.dart';
import 'package:movies_app/profile/presentation/views/rewards_view.dart';
import 'package:movies_app/profile/presentation/views/member_card_view.dart';
import 'package:movies_app/profile/presentation/views/my_coupons_view.dart';
import 'package:movies_app/fnb/presentation/views/fnb_orders_view.dart';
import 'package:movies_app/profile/data/datasource/profile_service.dart';

class AppRouter {
  static GoRouter createRouter() {
    final authNotifier = sl.isRegistered<AuthStateNotifier>() ? sl<AuthStateNotifier>() : null;

    return GoRouter(
      initialLocation: '/${AppRoutes.moviesRoute}',
      refreshListenable: authNotifier,
      debugLogDiagnostics: true, // Enable debug logging
      redirect: (context, state) async {
        final authService = sl<AuthService>();
        final loggedIn = authService.currentUser != null;
        final currentPath = state.uri.path;
        final matchedLocation = state.matchedLocation;

        // Check admin session first
        bool isAdminSession = false;
        try {
          if (sl.isRegistered<LocalAdminService>()) {
            isAdminSession = await sl<LocalAdminService>().isAdminLoggedIn();
          }
        } catch (_) {}

        final isAuthRoute = matchedLocation == '/${AppRoutes.authRoute}' ||
            matchedLocation == '/${AppRoutes.authRoute}/${AppRoutes.signInRoute}' ||
            matchedLocation == '/${AppRoutes.authRoute}/${AppRoutes.signUpRoute}' ||
            matchedLocation == '/${AppRoutes.authRoute}/${AppRoutes.adminSignInRoute}';

        // If trying to access admin route
        final tryingAdmin = currentPath.startsWith('/admin');
        if (tryingAdmin) {
          if (isAdminSession) {
            return null; // Allow access to admin
          }
          // Not admin, redirect to home
          return '/${AppRoutes.moviesRoute}';
        }

        // Root path redirect
        if (currentPath == '/') {
          return loggedIn ? '/${AppRoutes.moviesRoute}' : '/${AppRoutes.authRoute}/${AppRoutes.signInRoute}';
        }

        // Not logged in and not on auth route
        if (!loggedIn && !isAuthRoute) {
          return '/${AppRoutes.authRoute}/${AppRoutes.signInRoute}';
        }

        // Logged in and on auth route - but if admin, let them navigate freely
        if (loggedIn && isAuthRoute) {
          if (isAdminSession) {
            return null; // Admin can stay on auth page (they're about to navigate to /admin)
          }
          return '/${AppRoutes.moviesRoute}';
        }

        return null;
      },
      routes: [
        // Root redirect
        GoRoute(
          path: '/',
          redirect: (context, state) {
            final authService = sl<AuthService>();
            final loggedIn = authService.currentUser != null;
            return loggedIn ? '/${AppRoutes.moviesRoute}' : '/${AppRoutes.authRoute}/${AppRoutes.signInRoute}';
          },
        ),

        // Auth routes
        GoRoute(
          name: AppRoutes.authRoute,
          path: '/${AppRoutes.authRoute}',
          pageBuilder: (context, state) => const NoTransitionPage(child: LoginView()),
          routes: [
            GoRoute(
              name: AppRoutes.signInRoute,
              path: AppRoutes.signInRoute,
              pageBuilder: (context, state) => const NoTransitionPage(child: LoginView()),
            ),
            GoRoute(
              name: AppRoutes.signUpRoute,
              path: AppRoutes.signUpRoute,
              pageBuilder: (context, state) => const NoTransitionPage(child: SignUpView()),
            ),
            GoRoute(
              name: AppRoutes.adminSignInRoute,
              path: AppRoutes.adminSignInRoute,
              pageBuilder: (context, state) => const NoTransitionPage(child: AdminLoginView()),
            ),
          ],
        ),

        // Main shell with bottom nav
        ShellRoute(
          builder: (context, state, child) => MainPage(child: child),
          routes: [
            // Movies
            GoRoute(
              name: AppRoutes.moviesRoute,
              path: '/${AppRoutes.moviesRoute}',
              pageBuilder: (context, state) => const NoTransitionPage(child: MoviesView()),
              routes: [
                GoRoute(
                  name: AppRoutes.movieDetailsRoute,
                  path: '${AppRoutes.movieDetailsRoute}/:movieId',
                  pageBuilder: (context, state) {
                    final movieId = int.parse(state.pathParameters['movieId']!);
                    return CupertinoPage(child: MovieDetailsView(movieId: movieId));
                  },
                ),
              ],
            ),

            // Cinemas
            GoRoute(
              name: AppRoutes.cinemasRoute,
              path: '/${AppRoutes.cinemasRoute}',
              pageBuilder: (context, state) => const NoTransitionPage(child: CinemasView()),
              routes: [
                GoRoute(
                  name: AppRoutes.cinemaDetailsRoute,
                  path: AppRoutes.cinemaDetailsRoute,
                  pageBuilder: (context, state) {
                    final cinema = state.extra as Cinema;
                    return CupertinoPage(child: CinemaDetailsView(cinema: cinema));
                  },
                ),
                // Seat selection (nested under cinemas so ShellRoute remains)
                GoRoute(
                  name: AppRoutes.seatSelectionRoute,
                  path: AppRoutes.seatSelectionRoute,
                  pageBuilder: (context, state) {
                    final extra = state.extra;
                    if (extra is Map<String, dynamic> &&
                        extra['cinema'] is Cinema &&
                        extra['movieShowtime'] is MovieShowtime &&
                        extra['selectedTime'] is String) {
                      final cinema = extra['cinema'] as Cinema;
                      final movieShowtime = extra['movieShowtime'] as MovieShowtime;
                      final selectedTime = extra['selectedTime'] as String;
                      return CupertinoPage(child: SeatSelectionView(cinema: cinema, movieShowtime: movieShowtime, selectedTime: selectedTime));
                    }
                    return CupertinoPage(child: Scaffold(appBar: AppBar(title: const Text('Error')), body: const Center(child: Text('Invalid showtime data.'))));
                  },
                ),
                // Order summary (nested)
                GoRoute(
                  name: AppRoutes.orderSummaryRoute,
                  path: AppRoutes.orderSummaryRoute,
                  pageBuilder: (context, state) {
                    final extra = state.extra;
                    if (extra is TicketOrder) {
                      return CupertinoPage(child: OrderSummaryView(order: extra));
                    }
                    return CupertinoPage(child: Scaffold(appBar: AppBar(title: const Text('Error')), body: const Center(child: Text('Invalid order data.'))));
                  },
                ),
                // QRIS payment (nested)
                GoRoute(
                  name: AppRoutes.qrisPaymentRoute,
                  path: AppRoutes.qrisPaymentRoute,
                  pageBuilder: (context, state) {
                    final extra = state.extra;
                    if (extra is TicketOrder) {
                      return CupertinoPage(child: QrisPaymentView(order: extra));
                    }
                    return CupertinoPage(child: Scaffold(appBar: AppBar(title: const Text('Error')), body: const Center(child: Text('Invalid payment data.'))));
                  },
                ),
                // Bank transfer (nested)
                GoRoute(
                  name: AppRoutes.bankTransferRoute,
                  path: AppRoutes.bankTransferRoute,
                  pageBuilder: (context, state) {
                    final extra = state.extra;
                    if (extra is TicketOrder) {
                      return CupertinoPage(child: BankTransferPaymentView(order: extra));
                    }
                    return CupertinoPage(child: Scaffold(appBar: AppBar(title: const Text('Error')), body: const Center(child: Text('Invalid payment data.'))));
                  },
                ),
                // F&B selection (nested)
                GoRoute(
                  name: AppRoutes.fnbSelectionRoute,
                  path: AppRoutes.fnbSelectionRoute,
                  pageBuilder: (context, state) => CupertinoPage(child: const FnbSelectionView()),
                ),
              ],
            ),

            // My Tickets
            GoRoute(
              name: AppRoutes.myTicketsRoute,
              path: '/${AppRoutes.myTicketsRoute}',
              pageBuilder: (context, state) => const NoTransitionPage(child: MyTicketsView()),
              routes: [
                GoRoute(
                  name: AppRoutes.ticketDetailsRoute,
                  path: AppRoutes.ticketDetailsRoute,
                  pageBuilder: (context, state) {
                    final ticket = state.extra as TicketOrder;
                    return CupertinoPage(child: TicketDetailsView(ticket: ticket));
                  },
                ),
              ],
            ),

            // Profile
            GoRoute(
              name: AppRoutes.profileRoute,
              path: '/${AppRoutes.profileRoute}',
              pageBuilder: (context, state) => const NoTransitionPage(child: ProfileView()),
              routes: [
                GoRoute(
                  name: AppRoutes.editProfileRoute,
                  path: AppRoutes.editProfileRoute,
                  pageBuilder: (context, state) {
                    final profile = state.extra as UserProfile;
                    return CupertinoPage(child: EditProfileView(profile: profile));
                  },
                ),
              ],
            ),

            // FNB
            GoRoute(
              name: AppRoutes.fnbRoute,
              path: '/${AppRoutes.fnbRoute}',
              pageBuilder: (context, state) => const NoTransitionPage(child: FnbView()),
            ),

            // Notifications
            GoRoute(
              name: AppRoutes.notificationsRoute,
              path: '/${AppRoutes.notificationsRoute}',
              pageBuilder: (context, state) => const NoTransitionPage(child: NotificationsView()),
            ),

            // Watchlist (registered for bottom nav)
            GoRoute(
              name: AppRoutes.watchlistRoute,
              path: '/${AppRoutes.watchlistRoute}',
              pageBuilder: (context, state) => const NoTransitionPage(child: WatchlistView()),
            ),
            GoRoute(
              name: AppRoutes.rewardsRoute,
              path: '/rewards',
              builder: (context, state) {
                final profile = sl<ProfileService>();
                return FutureBuilder<UserProfile>(
                  future: profile.getProfile(),
                  builder: (ctx, snapshot) {
                    if (!snapshot.hasData) {
                      return const Scaffold(
                        backgroundColor: Color(0xFF141414),
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return RewardsView(profile: snapshot.data as UserProfile);
                  },
                );
              },
            ),
            GoRoute(
              name: AppRoutes.memberCardRoute,
              path: '/memberCard',
              builder: (context, state) {
                final extra = state.extra;
                if (extra is UserProfile) {
                  return MemberCardView(profile: extra);
                }
                final profile = sl<ProfileService>();
                return FutureBuilder<UserProfile>(
                  future: profile.getProfile(),
                  builder: (ctx, snapshot) {
                    if (!snapshot.hasData) {
                      return const Scaffold(
                        backgroundColor: Color(0xFF141414),
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return MemberCardView(profile: snapshot.data as UserProfile);
                  },
                );
              },
            ),

            // Other profile-related pages (promotions, news, facilities, partnership, faq, membership, menu)
            GoRoute(
              name: AppRoutes.promotionsRoute,
              path: '/${AppRoutes.promotionsRoute}',
              pageBuilder: (context, state) => const NoTransitionPage(child: PromotionsView()),
            ),
            GoRoute(
              name: AppRoutes.newsRoute,
              path: '/${AppRoutes.newsRoute}',
              pageBuilder: (context, state) => const NoTransitionPage(child: NewsView()),
            ),
            GoRoute(
              name: AppRoutes.facilitiesRoute,
              path: '/${AppRoutes.facilitiesRoute}',
              pageBuilder: (context, state) => const NoTransitionPage(child: FacilitiesView()),
            ),
            GoRoute(
              name: AppRoutes.partnershipRoute,
              path: '/${AppRoutes.partnershipRoute}',
              pageBuilder: (context, state) => const NoTransitionPage(child: PartnershipView()),
            ),
            GoRoute(
              name: AppRoutes.faqContactRoute,
              path: '/${AppRoutes.faqContactRoute}',
              pageBuilder: (context, state) => const NoTransitionPage(child: FaqContactView()),
            ),
            GoRoute(
              name: AppRoutes.membershipRoute,
              path: '/${AppRoutes.membershipRoute}',
              pageBuilder: (context, state) => const NoTransitionPage(child: MembershipView()),
            ),
            GoRoute(
              name: AppRoutes.rentRoute,
              path: '/${AppRoutes.rentRoute}',
              pageBuilder: (context, state) => const NoTransitionPage(child: RentView()),
            ),
            GoRoute(
              name: AppRoutes.sportsHallRoute,
              path: '/${AppRoutes.sportsHallRoute}',
              pageBuilder: (context, state) => const NoTransitionPage(child: SportsHallView()),
            ),
            GoRoute(
              name: AppRoutes.menuRoute,
              path: '/${AppRoutes.menuRoute}',
              pageBuilder: (context, state) => const NoTransitionPage(child: MenuView()),
            ),

            // F&B orders
            GoRoute(
              name: AppRoutes.fnbOrdersRoute,
              path: '/${AppRoutes.fnbOrdersRoute}',
              pageBuilder: (context, state) => const NoTransitionPage(child: FnbOrdersView()),
            ),

            // Location Selector
            GoRoute(
              name: AppRoutes.locationSelectorRoute,
              path: '/${AppRoutes.locationSelectorRoute}',
              pageBuilder: (context, state) => const CupertinoPage(child: LocationSelectorView()),
            ),

            // Search
            GoRoute(
              name: AppRoutes.searchRoute,
              path: '/${AppRoutes.searchRoute}',
              pageBuilder: (context, state) => const CupertinoPage(child: SearchView()),
            ),

            // My Coupons
            GoRoute(
              name: AppRoutes.myCouponsRoute,
              path: '/${AppRoutes.myCouponsRoute}',
              pageBuilder: (context, state) {
                final coupons = state.extra as List<String>? ?? [];
                return CupertinoPage(child: MyCouponsView(coupons: coupons));
              },
            ),

            // Recommendations (Weather-based)
            GoRoute(
              name: AppRoutes.recommendationsRoute,
              path: '/${AppRoutes.recommendationsRoute}',
              pageBuilder: (context, state) => const CupertinoPage(child: RecommendationView()),
            ),
          ],
        ),

        // Admin routes (outside ShellRoute - no bottom nav)
        getAdminRoute(),
      ],
    );
  }
}

