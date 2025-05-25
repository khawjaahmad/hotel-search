part of 'favorites_bloc.dart';

sealed class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object> get props => [];
}

final class FavoritesUpdatedEvent extends FavoritesEvent {
  const FavoritesUpdatedEvent({
    required this.items,
  });

  final List<Hotel> items;

  @override
  List<Object> get props => [items];
}

final class AddFavoriteEvent extends FavoritesEvent {
  const AddFavoriteEvent({
    required this.hotel,
  });

  final Hotel hotel;

  @override
  List<Object> get props => [hotel];
}

final class RemoveFavoriteEvent extends FavoritesEvent {
  const RemoveFavoriteEvent({
    required this.hotel,
  });

  final Hotel hotel;

  @override
  List<Object> get props => [hotel];
}
