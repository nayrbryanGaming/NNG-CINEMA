import 'package:equatable/equatable.dart';

abstract class RecommendationEvent extends Equatable {
  const RecommendationEvent();

  @override
  List<Object> get props => [];
}

/// Event to get weather-based recommendations
/// Set [forceRefresh] to true to bypass cache (e.g., when user manually taps refresh button)
class GetWeatherRecommendationEvent extends RecommendationEvent {
  final bool forceRefresh;

  const GetWeatherRecommendationEvent({this.forceRefresh = false});

  @override
  List<Object> get props => [forceRefresh];
}

class SearchEvent extends RecommendationEvent {
  final String query;

  const SearchEvent(this.query);

  @override
  List<Object> get props => [query];
}
