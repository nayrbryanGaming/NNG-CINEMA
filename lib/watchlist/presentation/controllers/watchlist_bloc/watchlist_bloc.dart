import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:movies_app/core/domain/entities/media.dart';
import 'package:movies_app/core/domain/usecase/base_use_case.dart';
import 'package:movies_app/core/services/firebase_watchlist_sync_service.dart';
import 'package:movies_app/core/services/auth_service.dart';
import 'package:movies_app/core/services/service_locator.dart' as global_sl;
import 'package:movies_app/watchlist/domain/usecases/add_watchlist_item_usecase.dart';
import 'package:movies_app/watchlist/domain/usecases/check_if_item_added_usecase.dart';
import 'package:movies_app/watchlist/domain/usecases/get_watchlist_items_usecase.dart';
import 'package:movies_app/watchlist/domain/usecases/remove_watchlist_item_usecase.dart';

part 'watchlist_event.dart';
part 'watchlist_state.dart';

class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  late final StreamSubscription? _authSub;

  WatchlistBloc(
    this._getWatchListItemsUseCase,
    this._addWatchListItemUseCase,
    this._removeWatchListItemUseCase,
    this._checkIfItemAddedUseCase,
  ) : super(const WatchlistState()) {
    on<GetWatchListItemsEvent>(_getWatchListItems);
    on<AddWatchListItemEvent>(_addWatchListItem);
    on<RemoveWatchListItemEvent>(_removeWatchListItem);
    on<CheckItemAddedEvent>(_checkItemAdded);
    // Listen to auth changes: when user logs in, refresh watchlist from remote
    final authService = global_sl.sl<AuthService>();
    _authSub = authService.authStateChanges().listen((user) {
      if (user != null) {
        add(GetWatchListItemsEvent());
      }
    });
  }

  final GetWatchlistItemsUseCase _getWatchListItemsUseCase;
  final AddWatchlistItemUseCase _addWatchListItemUseCase;
  final RemoveWatchlistItemUseCase _removeWatchListItemUseCase;
  final CheckIfItemAddedUseCase _checkIfItemAddedUseCase;
  final FirebaseWatchlistSyncService _syncService = GetIt.instance<FirebaseWatchlistSyncService>();

  Future<void> _getWatchListItems(
      WatchlistEvent event, Emitter<WatchlistState> emit) async {
    emit(
      const WatchlistState(
        status: WatchlistRequestStatus.loading,
      ),
    );
    final result = await _getWatchListItemsUseCase.call(const NoParameters());
    result.fold(
      (l) => emit(
        WatchlistState(
          status: WatchlistRequestStatus.error,
          message: l.message,
        ),
      ),
      (r) async {
        if (r.isEmpty) {
          emit(
            const WatchlistState(
              status: WatchlistRequestStatus.empty,
            ),
          );
        } else {
          final merged = await _syncService.fetchRemote(r);
          await _syncService.pushAll(merged);
          emit(
            WatchlistState(
              status: WatchlistRequestStatus.loaded,
              items: merged,
            ),
          );
        }
      },
    );
  }

  Future<void> _addWatchListItem(
      AddWatchListItemEvent event, Emitter<WatchlistState> emit) async {
    emit(
      const WatchlistState(
        status: WatchlistRequestStatus.loading,
      ),
    );
    final result = await _addWatchListItemUseCase.call(event.media);
    result.fold(
      (l) => emit(
        WatchlistState(
          status: WatchlistRequestStatus.error,
          message: l.message,
        ),
      ),
      (r) async {
        emit(
          WatchlistState(
            status: WatchlistRequestStatus.itemAdded,
            id: r,
          ),
        );
        await _syncService.add(event.media);
        // After adding locally and remote-add, fetch local list and perform a full merge+push
        final localResult = await _getWatchListItemsUseCase.call(const NoParameters());
        localResult.fold((l) => null, (local) async {
          final merged = await _syncService.fetchRemote(local);
          await _syncService.pushAll(merged);
        });
      },
    );
  }

  Future<void> _removeWatchListItem(
      RemoveWatchListItemEvent event, Emitter<WatchlistState> emit) async {
    emit(
      const WatchlistState(
        status: WatchlistRequestStatus.loading,
      ),
    );
    final result = await _removeWatchListItemUseCase.call(event.index);
    result.fold(
      (l) => emit(
        WatchlistState(
          status: WatchlistRequestStatus.error,
          message: l.message,
        ),
      ),
      (r) async {
        emit(
          const WatchlistState(
            status: WatchlistRequestStatus.itemRemoved,
          ),
        );
        // Use tmdbId for Firestore sync (not index)
        await _syncService.remove(event.tmdbId);
        // After removing, sync full list to remote to avoid inconsistencies
        final localResult = await _getWatchListItemsUseCase.call(const NoParameters());
        localResult.fold((l) => null, (local) async {
          final merged = await _syncService.fetchRemote(local);
          await _syncService.pushAll(merged);
        });
      },
    );
  }

  FutureOr<void> _checkItemAdded(
      CheckItemAddedEvent event, Emitter<WatchlistState> emit) async {
    emit(
      const WatchlistState(
        status: WatchlistRequestStatus.loading,
      ),
    );
    final result = await _checkIfItemAddedUseCase.call(event.tmdbId);
    result.fold(
      (l) => emit(
        WatchlistState(
          status: WatchlistRequestStatus.error,
          message: l.message,
        ),
      ),
      (r) => emit(
        WatchlistState(
          status: WatchlistRequestStatus.isItemAdded,
          id: r,
        ),
      ),
    );
  }

  @override
  Future<void> close() {
    _authSub?.cancel();
    return super.close();
  }
}
