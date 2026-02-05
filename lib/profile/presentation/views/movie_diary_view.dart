import 'package:flutter/material.dart';
import 'package:movies_app/core/presentation/components/shimmer_image.dart';
import 'package:movies_app/core/presentation/utils/color_utils.dart';

class MovieDiaryView extends StatefulWidget {
  const MovieDiaryView({super.key});

  @override
  State<MovieDiaryView> createState() => _MovieDiaryViewState();
}

class _MovieDiaryViewState extends State<MovieDiaryView> {
  // Mock data - bisa diganti dengan data dari API/Database
  final int totalMoviesWatched = 7;
  final int totalMinutesWatched = 848;
  final String mostWatchedGenre = 'DRAMA';
  final double genrePercentage = 43.0;
  final String favoriteCinema = 'Panakkukang Square';
  final String favoriteAuditorium = 'Audi 1';

  // Sample watched movies
  final List<Map<String, dynamic>> watchedMovies = [
    {
      'title': 'The Shawshank Redemption',
      'genre': 'Drama',
      'poster': 'https://image.tmdb.org/t/p/w500/q6y0Go1tsGEsmtFryDOJo3dEmqu.jpg',
      'rating': 9.3,
      'watchedDate': '2024-11-15',
    },
    {
      'title': 'The Godfather',
      'genre': 'Drama',
      'poster': 'https://image.tmdb.org/t/p/w500/3bhkrj58Vtu7enYsRolD1fZdja1.jpg',
      'rating': 9.2,
      'watchedDate': '2024-11-10',
    },
    {
      'title': 'The Dark Knight',
      'genre': 'Action',
      'poster': 'https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg',
      'rating': 9.0,
      'watchedDate': '2024-11-08',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF6B9D), // Pink gradient background
      body: CustomScrollView(
        slivers: [
          // AppBar with gradient
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: const Color(0xFFFF6B9D),
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Movie Diary',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Stack(
                children: [
                  // Background gradient
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFFF6B9D),
                          Color(0xFFFF8FAB),
                        ],
                      ),
                    ),
                  ),
                  // Diary illustration
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 80),
                        // Diary icon
                        Container(
                          padding: const EdgeInsets.all(40),
                          child: Icon(
                            Icons.menu_book_rounded,
                            size: 120,
                            color: withOpacityColor(Colors.white, 0.3),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Stats
                        Text(
                          '${genrePercentage.toInt()}% ${mostWatchedGenre.toUpperCase()}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your most favorite genre is $mostWatchedGenre by watching\n${(totalMoviesWatched * genrePercentage / 100).toInt()} $mostWatchedGenre movies',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: withOpacityColor(Colors.white, 0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Statistics section
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _buildStatCard(
                    icon: Icons.movie_outlined,
                    iconColor: Colors.red,
                    title: 'Total Movies Watched',
                    value: '$totalMoviesWatched Movies',
                  ),
                  const SizedBox(height: 12),
                  _buildStatCard(
                    icon: Icons.access_time_rounded,
                    iconColor: Colors.orange,
                    title: 'Total Minutes Watched',
                    value: '$totalMinutesWatched Minutes',
                  ),
                  const SizedBox(height: 12),
                  _buildStatCard(
                    icon: Icons.theater_comedy_rounded,
                    iconColor: Colors.pink,
                    title: 'Most Watched Genre',
                    value: mostWatchedGenre,
                  ),
                  const SizedBox(height: 12),
                  _buildStatCard(
                    icon: Icons.location_on_rounded,
                    iconColor: Colors.blue,
                    title: 'My Go-to Cinema',
                    value: favoriteCinema,
                  ),
                  const SizedBox(height: 12),
                  _buildStatCard(
                    icon: Icons.event_seat_rounded,
                    iconColor: Colors.purple,
                    title: 'My Favorite Special Auditorium',
                    value: favoriteAuditorium,
                  ),
                  const SizedBox(height: 24),

                  // Recently watched section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recently Watched',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'VIEW ALL',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Movie list
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: watchedMovies.length,
                    itemBuilder: (context, index) {
                      final movie = watchedMovies[index];
                      return _buildMovieCard(movie);
                    },
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: withOpacityColor(iconColor, 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: withOpacityColor(Colors.white, 0.6),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: withOpacityColor(Colors.white, 0.4),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieCard(Map<String, dynamic> movie) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Movie poster
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ShimmerImage(
              imageUrl: movie['poster'],
              width: 60,
              height: 90,
            ),
          ),
          const SizedBox(width: 16),
          // Movie info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: withOpacityColor(Colors.red, 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        movie['genre'],
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${movie['rating']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Watched: ${movie['watchedDate']}',
                  style: TextStyle(
                    color: withOpacityColor(Colors.white, 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

