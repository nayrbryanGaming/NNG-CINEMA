import 'package:equatable/equatable.dart';

abstract class RecommendationEvent extends Equatable {
  const RecommendationEvent();

  @override
  List<Object> get props => [];
}

class GetWeatherRecommendationEvent extends RecommendationEvent {}

class SearchEvent extends RecommendationEvent {
  final String query;

  const SearchEvent(this.query);

  @override
  List<Object> get props => [query];
}
