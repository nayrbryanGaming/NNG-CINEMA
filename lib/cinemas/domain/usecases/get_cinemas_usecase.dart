import 'package:dartz/dartz.dart';
import 'package:movies_app/core/data/error/failure.dart';
import 'package:movies_app/cinemas/domain/entities/cinema.dart';
import 'package:movies_app/cinemas/domain/repository/cinema_repository.dart';

class GetCinemasUseCase {
  final CinemaRepository repository;

  GetCinemasUseCase(this.repository);

  Future<Either<Failure, List<Cinema>>> call() async {
    return await repository.getCinemas();
  }
}
