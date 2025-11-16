import 'package:equatable/equatable.dart';
import 'package:movies_app/core/utils/enums.dart';
import 'package:movies_app/cinemas/domain/entities/cinema.dart';

abstract class CinemasState extends Equatable {
  const CinemasState();

  @override
  List<Object> get props => [];
}

class CinemasInitial extends CinemasState {}

class CinemasLoading extends CinemasState {}

class CinemasLoaded extends CinemasState {
  final List<Cinema> cinemas;

  const CinemasLoaded(this.cinemas);

  @override
  List<Object> get props => [cinemas];
}

class CinemasError extends CinemasState {
  final String message;

  const CinemasError(this.message);

  @override
  List<Object> get props => [message];
}
