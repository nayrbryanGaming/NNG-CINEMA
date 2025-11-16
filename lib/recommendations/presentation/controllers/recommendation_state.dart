import 'package:equatable/equatable.dart';
import 'package:movies_app/core/domain/entities/media.dart';

abstract class RecommendationState extends Equatable {
  const RecommendationState();

  @override
  List<Object> get props => [];
}

class RecommendationInitial extends RecommendationState {}

class RecommendationLoading extends RecommendationState {}

class RecommendationLoaded extends RecommendationState {
  final List<Media> movies;
  final String title;

  const RecommendationLoaded(this.movies, this.title);

  @override
  List<Object> get props => [movies, title];
}

class RecommendationError extends RecommendationState {
  final String message;

  const RecommendationError(this.message);

  @override
  List<Object> get props => [message];
}
