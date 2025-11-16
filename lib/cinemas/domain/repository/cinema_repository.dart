import 'package:dartz/dartz.dart';
import 'package:movies_app/core/data/error/failure.dart';
import 'package:movies_app/cinemas/domain/entities/cinema.dart';

abstract class CinemaRepository {
  Future<Either<Failure, List<Cinema>>> getCinemas();
}
