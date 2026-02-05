import 'package:movies_app/cinemas/domain/entities/cinema.dart';
import 'package:movies_app/cinemas/domain/entities/movie_showtime.dart';

abstract class CinemaLocalDataSource {
  Future<List<Cinema>> getCinemas();
}

class CinemaLocalDataSourceImpl implements CinemaLocalDataSource {
  // Popular movies data (cached untuk tidak boros API call)
  static const List<MovieShowtime> _popularMovies = [
    MovieShowtime(
      movieId: 1022789,
      title: 'Inside Out 2',
      posterUrl: 'https://image.tmdb.org/t/p/w500/vpnVM9B6NMmQpWeZvzLvDESb2QY.jpg',
      showtimes: ['12:00', '14:15', '16:30', '18:45', '21:00'],
    ),
    MovieShowtime(
      movieId: 786892,
      title: 'Furiosa: A Mad Max Saga',
      posterUrl: 'https://image.tmdb.org/t/p/w500/iADOJ8Zymht2JPMoy3R7xceMprA.jpg',
      showtimes: ['13:30', '16:30', '19:30', '22:30'],
    ),
    MovieShowtime(
      movieId: 653346,
      title: 'Kingdom of the Planet of the Apes',
      posterUrl: 'https://image.tmdb.org/t/p/w500/gKkl37BQuKTanygYQG1pyYgLVgf.jpg',
      showtimes: ['12:30', '15:00', '17:30', '20:00'],
    ),
    MovieShowtime(
      movieId: 573435,
      title: 'Bad Boys: Ride or Die',
      posterUrl: 'https://image.tmdb.org/t/p/w500/oGythE98MYleE6mZlGs5oBGkux1.jpg',
      showtimes: ['13:00', '15:30', '18:00', '20:30', '23:00'],
    ),
    MovieShowtime(
      movieId: 519182,
      title: 'Despicable Me 4',
      posterUrl: 'https://image.tmdb.org/t/p/w500/wWba3TaojhK7NdycRhoQpsG0FaH.jpg',
      showtimes: ['11:30', '13:45', '16:00', '18:15', '20:30'],
    ),
    MovieShowtime(
      movieId: 748783,
      title: 'The Garfield Movie',
      posterUrl: 'https://image.tmdb.org/t/p/w500/p6AbOJvMQhBmffd0PIv0u8ghWeY.jpg',
      showtimes: ['12:15', '14:30', '16:45', '19:00'],
    ),
    MovieShowtime(
      movieId: 1079091,
      title: 'It Ends with Us',
      posterUrl: 'https://image.tmdb.org/t/p/w500/4TzwDWpLmb9bWJjlN3iBUdvgarw.jpg',
      showtimes: ['13:15', '15:45', '18:15', '20:45'],
    ),
    MovieShowtime(
      movieId: 718821,
      title: 'Twisters',
      posterUrl: 'https://image.tmdb.org/t/p/w500/pjnD08FlMAIXsfOLKQbvmO0f0MD.jpg',
      showtimes: ['12:45', '15:15', '17:45', '20:15', '22:45'],
    ),
  ];

  @override
  Future<List<Cinema>> getCinemas() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Return 20+ cinemas dengan minimal 6 film per cinema
    return const [
      Cinema(
        id: 1,
        name: 'XXI Cibinong City Mall',
        location: 'Jl. Tegar Beriman No. 1, Pakansari, Cibinong',
        movieShowtimes: _popularMovies,
      ),
      Cinema(
        id: 2,
        name: 'CGV Vivo Sentul',
        location: 'Vivo Mall, Jl. Raya Bogor KM 50, Sentul',
        movieShowtimes: _popularMovies,
      ),
      Cinema(
        id: 3,
        name: 'Cinere Bellevue XXI',
        location: 'Cinere Bellevue Mall, Jl. Cinere Raya, Cinere',
        movieShowtimes: _popularMovies,
      ),
      Cinema(
        id: 4,
        name: 'CGV Grand Indonesia',
        location: 'Grand Indonesia Shopping Town, Jakarta Pusat',
        movieShowtimes: _popularMovies,
      ),
      Cinema(
        id: 5,
        name: 'XXI Plaza Senayan',
        location: 'Plaza Senayan, Jl. Asia Afrika, Jakarta Selatan',
        movieShowtimes: _popularMovies,
      ),
      Cinema(
        id: 6,
        name: 'Cinepolis Lippo Mall Puri',
        location: 'Lippo Mall Puri, Jl. Puri Indah, Jakarta Barat',
        movieShowtimes: _popularMovies,
      ),
      Cinema(
        id: 7,
        name: 'XXI Pondok Indah Mall',
        location: 'Pondok Indah Mall, Jl. Metro Pondok Indah, Jakarta Selatan',
        movieShowtimes: _popularMovies,
      ),
      Cinema(
        id: 8,
        name: 'CGV Pacific Place',
        location: 'Pacific Place, Jl. Jend. Sudirman, Jakarta Selatan',
        movieShowtimes: _popularMovies,
      ),
      Cinema(
        id: 9,
        name: 'XXI Summarecon Mal Bekasi',
        location: 'Summarecon Mal Bekasi, Jl. Boulevard Ahmad Yani, Bekasi',
        movieShowtimes: _popularMovies,
      ),
      Cinema(
        id: 10,
        name: 'Cinepolis Aeon Mall BSD',
        location: 'Aeon Mall BSD City, Jl. BSD Raya Utama, Tangerang',
        movieShowtimes: _popularMovies,
      ),
      Cinema(
        id: 11,
        name: 'XXI Mall Kelapa Gading',
        location: 'Mall Kelapa Gading, Jl. Boulevard Kelapa Gading, Jakarta Utara',
        movieShowtimes: _popularMovies,
      ),
      Cinema(
        id: 12,
        name: 'CGV Central Park',
        location: 'Central Park Mall, Jl. Letjen S. Parman, Jakarta Barat',
        movieShowtimes: _popularMovies,
      ),
      Cinema(
        id: 13,
        name: 'XXI Kota Kasablanka',
        location: 'Kota Kasablanka, Jl. Casablanca Raya, Jakarta Selatan',
        movieShowtimes: _popularMovies,
      ),
      Cinema(
        id: 14,
        name: 'Cinepolis Living World Alam Sutera',
        location: 'Living World, Jl. Alam Sutera Boulevard, Tangerang',
        movieShowtimes: _popularMovies,
      ),
      Cinema(
        id: 15,
        name: 'XXI Mall Taman Anggrek',
        location: 'Mall Taman Anggrek, Jl. Letjen S. Parman, Jakarta Barat',
        movieShowtimes: _popularMovies,
      ),
      Cinema(
        id: 16,
        name: 'CGV Paris Van Java',
        location: 'Paris Van Java Mall, Jl. Sukajadi, Bandung',
        movieShowtimes: _popularMovies,
      ),
      Cinema(
        id: 17,
        name: 'XXI Ciputra World Surabaya',
        location: 'Ciputra World, Jl. Mayjend Sungkono, Surabaya',
        movieShowtimes: _popularMovies,
      ),
      Cinema(
        id: 18,
        name: 'Cinepolis Mal Ciputra Jakarta',
        location: 'Mal Ciputra, Jl. Arteri S. Parman, Jakarta Barat',
        movieShowtimes: _popularMovies,
      ),
      Cinema(
        id: 19,
        name: 'XXI Plaza Indonesia',
        location: 'Plaza Indonesia, Jl. MH Thamrin, Jakarta Pusat',
        movieShowtimes: _popularMovies,
      ),
      Cinema(
        id: 20,
        name: 'CGV fx Sudirman',
        location: 'fX Sudirman, Jl. Jend. Sudirman, Jakarta Pusat',
        movieShowtimes: _popularMovies,
      ),
      Cinema(
        id: 21,
        name: 'XXI Cilandak Town Square',
        location: 'Cilandak Town Square, Jl. TB Simatupang, Jakarta Selatan',
        movieShowtimes: _popularMovies,
      ),
      Cinema(
        id: 22,
        name: 'Cinepolis Metropolitan Mall Bekasi',
        location: 'Metropolitan Mall, Jl. Ahmad Yani, Bekasi',
        movieShowtimes: _popularMovies,
      ),
      Cinema(
        id: 23,
        name: 'XXI Gandaria City',
        location: 'Gandaria City, Jl. Sultan Iskandar Muda, Jakarta Selatan',
        movieShowtimes: _popularMovies,
      ),
      Cinema(
        id: 24,
        name: 'CGV Mall of Indonesia',
        location: 'Mall of Indonesia, Jl. Boulevard Barat Raya, Jakarta Utara',
        movieShowtimes: _popularMovies,
      ),
      Cinema(
        id: 25,
        name: 'XXI Emporium Pluit Mall',
        location: 'Emporium Pluit Mall, Jl. Pluit Selatan Raya, Jakarta Utara',
        movieShowtimes: _popularMovies,
      ),
    ];
  }
}
