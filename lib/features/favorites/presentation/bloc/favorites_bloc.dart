import 'dart:async';
import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:hotel_booking/features/favorites/domain/usecases/usecases.dart';
import 'package:hotel_booking/features/hotels/domain/entities/entities.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetFavoritesUseCase _getFavoritesUseCase;
  final WatchFavoritesUseCase _watchFavoritesUseCase;
  final AddFavoriteUseCase _addFavoriteUseCase;
  final RemoveFavoriteUseCase _removeFavoriteUseCase;
  late final StreamSubscription<List<Hotel>> _favoritesSubscription;

  FavoritesBloc({
    required GetFavoritesUseCase getFavoritesUseCase,
    required WatchFavoritesUseCase watchFavoritesUseCase,
    required AddFavoriteUseCase addFavoriteUseCase,
    required RemoveFavoriteUseCase removeFavoriteUseCase,
  })  : _getFavoritesUseCase = getFavoritesUseCase,
        _watchFavoritesUseCase = watchFavoritesUseCase,
        _addFavoriteUseCase = addFavoriteUseCase,
        _removeFavoriteUseCase = removeFavoriteUseCase,
        super(FavoritesState(items: [])) {
    on<AddFavoriteEvent>(_addFavorite);
    on<RemoveFavoriteEvent>(_removeFavorite);
    on<FavoritesUpdatedEvent>(_updateFavorites);
    _init();
  }

  void _init() {
    add(FavoritesUpdatedEvent(items: _getFavoritesUseCase.call()));
    _favoritesSubscription = _watchFavoritesUseCase.call().listen((items) {
      add(FavoritesUpdatedEvent(items: items));
    });
  }

  @override
  Future<void> close() {
    _favoritesSubscription.cancel();
    return super.close();
  }

  void _updateFavorites(
    FavoritesUpdatedEvent event,
    Emitter<FavoritesState> emit,
  ) {
    emit(FavoritesState(items: event.items));
  }

  void _addFavorite(
    AddFavoriteEvent event,
    Emitter<FavoritesState> emit,
  ) {
    _addFavoriteUseCase.call(event.hotel);
  }

  void _removeFavorite(
    RemoveFavoriteEvent event,
    Emitter<FavoritesState> emit,
  ) {
    _removeFavoriteUseCase.call(event.hotel);
  }
}
