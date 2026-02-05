part of 'watchlist_bloc.dart';

abstract class WatchlistEvent extends Equatable {
  const WatchlistEvent();
}

class GetWatchListItemsEvent extends WatchlistEvent {
  @override
  List<Object?> get props => [];
}

class AddWatchListItemEvent extends WatchlistEvent {
  final Media media;

  const AddWatchListItemEvent({
    required this.media,
  });

  @override
  List<Object?> get props => [media];
}

class RemoveWatchListItemEvent extends WatchlistEvent {
  final int index;
  final int tmdbId;

  const RemoveWatchListItemEvent(this.index, {required this.tmdbId});

  @override
  List<Object?> get props => [index, tmdbId];
}

class CheckItemAddedEvent extends WatchlistEvent {
  final int tmdbId;

  const CheckItemAddedEvent({
    required this.tmdbId,
  });

  @override
  List<Object?> get props => [tmdbId];
}
