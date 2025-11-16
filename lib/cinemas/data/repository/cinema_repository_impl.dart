import 'package:dartz/dartz.dart';
import 'package:movies_app/core/data/error/failure.dart';
import 'package:movies_app/cinemas/domain/entities/cinema.dart';
import 'package:movies_app/cinemas/domain/repository/cinema_repository.dart';
import 'package:movies_app/cinemas/data/datasource/cinema_local_data_source.dart';

class CinemaRepositoryImpl implements CinemaRepository {
  final CinemaLocalDataSource localDataSource;

  CinemaRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Cinema>>> getCinemas() async {
    try {
      final cinemas = await localDataSource.getCinemas();
      return Right(cinemas);
    } catch (e) {
      return Left(ServerFailure('An error occurred while fetching cinemas.'));
    }
  }
}
