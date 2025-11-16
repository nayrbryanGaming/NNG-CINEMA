import 'package:movies_app/cinemas/domain/entities/cinema.dart';
import 'package:movies_app/cinemas/domain/entities/movie_showtime.dart';

abstract class CinemaLocalDataSource {
  Future<List<Cinema>> getCinemas();
}

class CinemaLocalDataSourceImpl implements CinemaLocalDataSource {
  @override
  Future<List<Cinema>> getCinemas() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Dummy data
    return [
      const Cinema(
        id: 1,
        name: 'XXI Cibinong City Mall',
        location: 'Jl. Tegar Beriman No. 1, Pakansari',
        movieShowtimes: [
          MovieShowtime(
            movieId: 1022789,
            title: 'Inside Out 2',
            posterUrl: 'https://image.tmdb.org/t/p/w500/gMBdJpkdS3eZFFH83sUjU5iR3a.jpg',
            showtimes: ['12:30', '14:45', '17:00', '19:15', '21:30'],
          ),
          MovieShowtime(
            movieId: 653346,
            title: 'Kingdom of the Planet of the Apes',
            posterUrl: 'https://image.tmdb.org/t/p/w500/gKkl37BQuKTanygYQG1pyYgLVgf.jpg',
            showtimes: ['13:00', '16:00', '19:00', '22:00'],
          ),
        ],
      ),
      const Cinema(
        id: 2,
        name: 'CGV Vivo Sentul',
        location: 'Vivo Mall, Jl. Raya Bogor KM 50',
        movieShowtimes: [
          MovieShowtime(
            movieId: 1022789,
            title: 'Inside Out 2',
            posterUrl: 'https://image.tmdb.org/t/p/w500/gMBdJpkdS3eZFFH83sUjU5iR3a.jpg',
            showtimes: ['12:00', '14:15', '16:30', '18:45', '21:00'],
          ),
          MovieShowtime(
            movieId: 786892,
            title: 'Furiosa: A Mad Max Saga',
            posterUrl: 'https://image.tmdb.org/t/p/w500/iADOJ8Zymht2JPMoy3R7xceMprA.jpg',
            showtimes: ['13:30', '16:30', '19:30', '22:30'],
          ),
        ],
      ),
      const Cinema(
        id: 3,
        name: 'Cinere Bellevue XXI',
        location: 'Cinere Bellevue Mall, Jl. Cinere Raya',
        movieShowtimes: [], // No movies for this cinema yet
      ),
    ];
  }
}
