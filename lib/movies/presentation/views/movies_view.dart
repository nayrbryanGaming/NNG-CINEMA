import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:movies_app/core/domain/entities/media.dart';
import 'package:movies_app/core/presentation/components/error_screen.dart';
import 'package:movies_app/core/presentation/components/loading_indicator.dart';
import 'package:movies_app/core/resources/app_routes.dart';

import 'package:movies_app/core/presentation/components/section_listview_card.dart';
import 'package:movies_app/core/presentation/components/section_header.dart';
import 'package:movies_app/core/presentation/components/section_listview.dart';
import 'package:movies_app/core/resources/app_strings.dart';
import 'package:movies_app/core/resources/app_values.dart';
import 'package:movies_app/core/services/service_locator.dart';
import 'package:movies_app/core/utils/enums.dart';
import 'package:movies_app/movies/presentation/controllers/movies_bloc/movies_bloc.dart';
import 'package:movies_app/movies/presentation/controllers/movies_bloc/movies_event.dart';
import 'package:movies_app/movies/presentation/controllers/movies_bloc/movies_state.dart';

// Recommendation imports (migrated into Home)
import 'package:movies_app/recommendations/presentation/controllers/recommendation_bloc.dart';
import 'package:movies_app/recommendations/presentation/controllers/recommendation_event.dart';
import 'package:movies_app/recommendations/presentation/controllers/recommendation_state.dart';
import 'package:movies_app/core/presentation/components/vertical_listview.dart';
import 'package:movies_app/core/presentation/components/vertical_listview_card.dart';

class MoviesView extends StatelessWidget {
  const MoviesView({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide both MoviesBloc and RecommendationBloc to the Home screen
    return MultiBlocProvider(
      providers: [
        BlocProvider<MoviesBloc>(
          create: (context) {
            final bloc = sl<MoviesBloc>();
            // Trigger event immediately but non-blocking
            Future.microtask(() => bloc.add(GetMoviesEvent()));
            return bloc;
          },
        ),
        BlocProvider<RecommendationBloc>(
          create: (context) => sl<RecommendationBloc>(),
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFF141414), // Explicit background to prevent black screen
        body: BlocBuilder<MoviesBloc, MoviesState>(
          builder: (context, state) {
            switch (state.status) {
              case RequestStatus.loading:
                return const LoadingIndicator();
              case RequestStatus.loaded:
                return MoviesWidget(
                  nowPlayingMovies: state.movies[0],
                  popularMovies: state.movies[1],
                  topRatedMovies: state.movies[2],
                );
              case RequestStatus.error:
                return ErrorScreen(
                  onTryAgainPressed: () {
                    context.read<MoviesBloc>().add(GetMoviesEvent());
                  },
                );
            }
          },
        ),
      ),
    );
  }
}

class MoviesWidget extends StatefulWidget {
  final List<Media> nowPlayingMovies;
  final List<Media> popularMovies;
  final List<Media> topRatedMovies;

  const MoviesWidget({
    super.key,
    required this.nowPlayingMovies,
    required this.popularMovies,
    required this.topRatedMovies,
  });

  @override
  State<MoviesWidget> createState() => _MoviesWidgetState();
}

class _MoviesWidgetState extends State<MoviesWidget> {
  String selectedLocation = 'MAKASSAR';
  bool _weatherFetched = false;

  @override
  void initState() {
    super.initState();
    // Only fetch weather ONCE when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_weatherFetched) {
        try {
          context.read<RecommendationBloc>().add(const GetWeatherRecommendationEvent());
          _weatherFetched = true;
        } catch (e) {
          // Ignore if bloc not available
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App Bar with Logo, Search, Profile, Notification
          _buildAppBar(context),

          // Location Selector
          _buildLocationSelector(context),

          // Promo Banner
          _buildPromoBanner(context),

          // User Level & Points Section
          _buildUserLevelSection(context),

          const SizedBox(height: AppSize.s16),

          // Recommendation Section (migrated from Recommendation screen)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppPadding.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeaderWidget(
                  title: 'Recommendations',
                  subtitle: 'Find movies by weather or search',
                  onSeeAllTap: () {
                    // Keep behavior minimal: navigate to the full Recommendation page if needed
                    context.go('/recommendations');
                  },
                ),
                const SizedBox(height: AppSize.s12),
                // Search Bar (sends SearchEvent to RecommendationBloc)
                TextField(
                  onChanged: (query) {
                    context.read<RecommendationBloc>().add(SearchEvent(query));
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Cari film, acara TV, atau genre...',
                    hintStyle: const TextStyle(color: Color.fromRGBO(255,255,255,0.7)),
                    prefixIcon: const Icon(Icons.search, color: Color.fromRGBO(255,255,255,0.7)),
                    filled: true,
                    fillColor: const Color.fromRGBO(33,33,33,1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSize.s8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: AppSize.s12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Manual tap = force refresh to get fresh weather data
                          context.read<RecommendationBloc>().add(const GetWeatherRecommendationEvent(forceRefresh: true));
                        },
                        icon: const Icon(Icons.wb_sunny_rounded),
                        label: const Text('Rekomendasi Berdasarkan Cuaca'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSize.s8),
                    IconButton(
                      onPressed: () {
                        // Manual refresh = force refresh to bypass cache
                        context.read<RecommendationBloc>().add(const GetWeatherRecommendationEvent(forceRefresh: true));
                      },
                      icon: const Icon(Icons.refresh, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: AppSize.s12),
                // Results from RecommendationBloc
                SizedBox(
                  height: 220,
                  child: BlocBuilder<RecommendationBloc, RecommendationState>(
                    builder: (context, state) {
                      if (state is RecommendationLoading) {
                        return const Center(child: LoadingIndicator());
                      }
                      if (state is RecommendationLoaded) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(state.title, style: Theme.of(context).textTheme.titleLarge),
                            ),
                            // Show the reason/explanation (pulled from Weather API via WeatherService)
                            if (state.reason != null && state.reason!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  state.reason!,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                                ),
                              ),
                            Expanded(
                              child: VerticalListView(
                                itemCount: state.movies.length,
                                itemBuilder: (context, index) {
                                  return VerticalListViewCard(media: state.movies[index]);
                                },
                                addEvent: () {},
                              ),
                            ),
                          ],
                        );
                      }
                      if (state is RecommendationError) {
                        return Center(child: Text(state.message));
                      }
                      return const Center(
                        child: Text('Hasil rekomendasi akan muncul di sini.', style: TextStyle(color: Colors.white)),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSize.s16),
              ],
            ),
          ),

          const SizedBox(height: AppSize.s16),
          // Search Navigator - placed below recommendations to separate concerns
          ElevatedButton.icon(
            onPressed: () {
              context.goNamed(AppRoutes.searchRoute);
            },
            icon: const Icon(Icons.search, color: Colors.white),
            label: const Text('Cari film, acara TV, atau genre...', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(33,33,33,1),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSize.s8)),
              alignment: Alignment.centerLeft,
            ),
          ),
          const SizedBox(height: AppSize.s16),

          // Explore Movies Section with Ranking
          SectionHeaderWidget(
            title: 'Explore Movies',
            subtitle: 'Exciting movies that will entertain you!',
            onSeeAllTap: () {
              context.goNamed(AppRoutes.popularMoviesRoute);
            },
          ),
          _buildRankedMovieList(context, widget.nowPlayingMovies),

          const SizedBox(height: AppSize.s16),

          SectionHeaderWidget(
            title: AppStrings.popularMovies,
            onSeeAllTap: () {
              context.goNamed(AppRoutes.popularMoviesRoute);
            },
          ),
          SectionListView(
            height: AppSize.s240,
            itemCount: widget.popularMovies.length,
            itemBuilder: (context, index) {
              return SectionListViewCard(media: widget.popularMovies[index]);
            },
          ),
          SectionHeaderWidget(
            title: AppStrings.topRatedMovies,
            onSeeAllTap: () {
              context.goNamed(AppRoutes.topRatedMoviesRoute);
            },
          ),
          SectionListView(
            height: AppSize.s240,
            itemCount: widget.topRatedMovies.length,
            itemBuilder: (context, index) {
              return SectionListViewCard(media: widget.topRatedMovies[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.p16, vertical: AppPadding.p12),
      color: Colors.black,
      child: SafeArea(
        child: Row(
          children: [
            // CGV Logo
            Image.asset(
              'assets/images/nng.png',
              height: 40,
              width: 80,
              fit: BoxFit.contain,
            ),
            const Spacer(),
            // Search Icon
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                // Navigate to search page
                context.goNamed(AppRoutes.searchRoute);
              },
            ),
            // Profile Icon
            IconButton(
              icon: const Icon(Icons.person_outline, color: Colors.white),
              onPressed: () {
                context.goNamed(AppRoutes.profileRoute);
              },
            ),
            // Notification Icon with badge
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                  onPressed: () {
                    context.goNamed(AppRoutes.notificationsRoute);
                  },
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: const Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSelector(BuildContext context) {
    return InkWell(
      onTap: () async {
        final result = await context.pushNamed<String>(AppRoutes.locationSelectorRoute);
        if (result != null && mounted) {
          setState(() {
            selectedLocation = result;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppPadding.p16, vertical: AppPadding.p12),
        color: const Color.fromRGBO(33,33,33,1),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.white, size: 20),
            const SizedBox(width: AppSize.s8),
            Text(
              selectedLocation,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: AppSize.s4),
            const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppPadding.p16),
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color.fromRGBO(233,30,99,1), const Color.fromRGBO(244,67,54,1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSize.s12),
      ),
      child: Stack(
        children: [
          // Background pattern or image
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSize.s12),
              child: Opacity(
                opacity: 0.3,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, const Color.fromRGBO(0,0,0,0.5)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Promo Content
          Padding(
            padding: const EdgeInsets.all(AppPadding.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'BUY 1 GET 1',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'FREE TICKET',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSize.s12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppPadding.p12,
                    vertical: AppPadding.p8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255,255,255,0.2),
                    borderRadius: BorderRadius.circular(AppSize.s8),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PERIODE PROMO:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '17-21 NOVEMBER 2025',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: AppSize.s4),
                      Text(
                        '*Kuota terbatas',
                        style: TextStyle(
                          color: Color.fromRGBO(255,255,255,0.7),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserLevelSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppPadding.p16),
      padding: const EdgeInsets.all(AppPadding.p16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(33,33,33,1),
        borderRadius: BorderRadius.circular(AppSize.s12),
      ),
      child: Row(
        children: [
          // Level
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppPadding.p8),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(AppSize.s8),
                  ),
                  child: const Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSize.s12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LEVEL',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'CLASSIC',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Color.fromRGBO(117,117,117,1),
          ),
          // Points
          Expanded(
            child: Row(
              children: [
                const SizedBox(width: AppSize.s12),
                Container(
                  padding: const EdgeInsets.all(AppPadding.p8),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(AppSize.s8),
                  ),
                  child: const Icon(
                    Icons.monetization_on,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSize.s12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'POINTS',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '0',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Color.fromRGBO(117,117,117,1),
          ),
          // BluAccount
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: AppPadding.p12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'BLUACCOUNT',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    'Not Linked',
                    style: TextStyle(
                      color: Color.fromRGBO(158,158,158,1),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankedMovieList(BuildContext context, List<Media> movies) {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppPadding.p12),
        itemCount: movies.length > 10 ? 10 : movies.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              context.goNamed(
                AppRoutes.movieDetailsRoute,
                pathParameters: {'movieId': movies[index].tmdbID.toString()},
              );
            },
            child: Container(
              width: 160,
              margin: const EdgeInsets.symmetric(horizontal: AppPadding.p4),
              child: Stack(
                children: [
                  // Movie Poster
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSize.s8),
                    child: Image.network(
                      movies[index].posterUrl,
                      height: 240,
                      width: 160,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 240,
                          width: 160,
                          color: Color.fromRGBO(33,33,33,1),
                          child: const Icon(
                            Icons.movie,
                            color: Colors.grey,
                            size: 50,
                          ),
                        );
                      },
                    ),
                  ),
                  // Ranking Badge
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(AppSize.s8),
                          bottomRight: Radius.circular(AppSize.s8),
                        ),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Age Rating Badge (if available)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(0,0,0,0.7),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: const Text(
                        '13+',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Movie Info at bottom
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(AppPadding.p8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, const Color.fromRGBO(0,0,0,0.9)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(AppSize.s8),
                          bottomRight: Radius.circular(AppSize.s8),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            movies[index].title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                movies[index].voteAverage.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.favorite,
                                color: Colors.red,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${(movies[index].voteAverage * 100).toInt()}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
