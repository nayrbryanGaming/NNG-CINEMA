import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
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
import 'package:movies_app/core/presentation/pages/main_page.dart';
import 'package:movies_app/movies/presentation/views/movie_details_view.dart';
import 'package:movies_app/movies/presentation/views/movies_view.dart';
import 'package:movies_app/movies/presentation/views/popular_movies_view.dart';
import 'package:movies_app/movies/presentation/views/top_rated_movies_view.dart';
import 'package:movies_app/profile/domain/entities/user_profile.dart';
import 'package:movies_app/profile/presentation/views/edit_profile_view.dart';
import 'package:movies_app/profile/presentation/views/my_coupons_view.dart';
import 'package:movies_app/profile/presentation/views/profile_view.dart';
import 'package:movies_app/recommendations/presentation/views/recommendation_view.dart';
import 'package:movies_app/tv_shows/presentation/views/popular_tv_shows_view.dart';
import 'package:movies_app/tv_shows/presentation/views/top_rated_tv_shows_view.dart';
import 'package:movies_app/tv_shows/presentation/views/tv_show_details_view.dart';
import 'package:movies_app/tv_shows/presentation/views/tv_shows_view.dart';
import 'package:movies_app/core/resources/app_routes.dart';

/// Semua path route utama
const String moviesPath = '/movies';
const String movieDetailsPath = 'movieDetails/:movieId';
const String popularMoviesPath = 'popularMovies';
const String topRatedMoviesPath = 'topRatedMovies';

const String tvShowsPath = '/tvShows';
const String tvShowDetailsPath = 'tvShowDetails/:tvShowId';
const String popularTVShowsPath = 'popularTVShows';
const String topRatedTVShowsPath = 'topRatedTVShows';

const String cinemasPath = '/cinemas';
const String cinemaDetailsPath = 'cinemaDetails';
const String seatSelectionPath = 'seatSelection';
const String orderSummaryPath = 'orderSummary';
const String qrisPaymentPath = 'qrisPayment';
const String myTicketsPath = '/myTickets';
const String ticketDetailsPath = 'ticketDetails';

const String recommendationsPath = '/recommendations';
const String profilePath = '/profile';
const String editProfilePath = 'editProfile';
const String myCouponsPath = 'myCoupons';

/// ✅ FIX: jadikan router sebagai `static final` agar bisa diakses langsung lewat `AppRouter.router`
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: moviesPath,
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainPage(child: child),
        routes: [
          GoRoute(
            name: AppRoutes.moviesRoute,
            path: moviesPath,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MoviesView(),
            ),
            routes: [
              GoRoute(
                name: AppRoutes.movieDetailsRoute,
                path: movieDetailsPath,
                pageBuilder: (context, state) => CupertinoPage(
                  child: MovieDetailsView(
                    movieId: int.parse(state.pathParameters['movieId'] ?? '0'),
                  ),
                ),
              ),
              GoRoute(
                name: AppRoutes.popularMoviesRoute,
                path: popularMoviesPath,
                pageBuilder: (context, state) => const CupertinoPage(
                  child: PopularMoviesView(),
                ),
              ),
              GoRoute(
                name: AppRoutes.topRatedMoviesRoute,
                path: topRatedMoviesPath,
                pageBuilder: (context, state) => const CupertinoPage(
                  child: TopRatedMoviesView(),
                ),
              ),
            ],
          ),
          GoRoute(
            name: AppRoutes.tvShowsRoute,
            path: tvShowsPath,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TVShowsView(),
            ),
            routes: [
              GoRoute(
                name: AppRoutes.tvShowDetailsRoute,
                path: tvShowDetailsPath,
                pageBuilder: (context, state) => CupertinoPage(
                  child: TVShowDetailsView(
                    tvShowId: int.parse(state.pathParameters['tvShowId'] ?? '0	'),
                  ),
                ),
              ),
              GoRoute(
                name: AppRoutes.popularTvShowsRoute,
                path: popularTVShowsPath,
                pageBuilder: (context, state) => const CupertinoPage(
                  child: PopularTVShowsView(),
                ),
              ),
              GoRoute(
                name: AppRoutes.topRatedTvShowsRoute,
                path: topRatedTVShowsPath,
                pageBuilder: (context, state) => const CupertinoPage(
                  child: TopRatedTVShowsView(),
                ),
              ),
            ],
          ),
          GoRoute(
            name: AppRoutes.cinemasRoute,
            path: cinemasPath,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CinemasView(),
            ),
            routes: [
              GoRoute(
                  name: AppRoutes.cinemaDetailsRoute,
                  path: cinemaDetailsPath,
                  pageBuilder: (context, state) {
                    final cinema = state.extra as Cinema;
                    return CupertinoPage(
                      child: CinemaDetailsView(cinema: cinema),
                    );
                  },
                  routes: [
                    GoRoute(
                        name: AppRoutes.seatSelectionRoute,
                        path: seatSelectionPath,
                        pageBuilder: (context, state) {
                          final args = state.extra as Map<String, dynamic>;
                          final cinema = args['cinema'] as Cinema;
                          final movieShowtime = args['movieShowtime'] as MovieShowtime;
                          final selectedTime = args['selectedTime'] as String;
                          return CupertinoPage(
                            child: SeatSelectionView(
                              cinema: cinema,
                              movieShowtime: movieShowtime,
                              selectedTime: selectedTime,
                            ),
                          );
                        },
                        routes: [
                          GoRoute(
                              name: AppRoutes.orderSummaryRoute,
                              path: orderSummaryPath,
                              pageBuilder: (context, state) {
                                final order = state.extra as TicketOrder;
                                return CupertinoPage(
                                  child: OrderSummaryView(order: order),
                                );
                              },
                              routes: [
                                GoRoute(
                                  name: AppRoutes.qrisPaymentRoute,
                                  path: qrisPaymentPath,
                                  pageBuilder: (context, state) {
                                    final order = state.extra as TicketOrder;
                                    return CupertinoPage(
                                      child: QrisPaymentView(order: order),
                                    );
                                  },
                                ),
                              ]),
                        ]),
                  ]),
            ],
          ),
          GoRoute(
              name: AppRoutes.myTicketsRoute,
              path: myTicketsPath,
              pageBuilder: (context, state) => const NoTransitionPage(
                    child: MyTicketsView(),
                  ),
              routes: [
                GoRoute(
                  name: AppRoutes.ticketDetailsRoute,
                  path: ticketDetailsPath,
                  pageBuilder: (context, state) {
                    final ticket = state.extra as TicketOrder;
                    return CupertinoPage(
                      child: TicketDetailsView(ticket: ticket),
                    );
                  },
                ),
              ]),
          GoRoute(
            name: AppRoutes.recommendationsRoute, // Changed from searchRoute
            path: recommendationsPath,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: RecommendationView(),
            ),
          ),
          GoRoute(
            name: AppRoutes.profileRoute,
            path: profilePath,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileView(),
            ),
            routes: [
              GoRoute(
                name: AppRoutes.editProfileRoute,
                path: editProfilePath,
                pageBuilder: (context, state) {
                  final profile = state.extra as UserProfile;
                  return CupertinoPage(
                    child: EditProfileView(profile: profile),
                  );
                },
              ),
              GoRoute(
                name: AppRoutes.myCouponsRoute,
                path: myCouponsPath,
                pageBuilder: (context, state) {
                  final coupons = state.extra as List<String>;
                  return CupertinoPage(
                    child: MyCouponsView(coupons: coupons),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
