part of 'favorites_bloc.dart';

class FavoritesState extends Equatable {
  FavoritesState({
    required this.items,
  });

  final List<Hotel> items;

  late final _items = HashSet.of(items);

  bool contains(Hotel hotel) => _items.contains(hotel);

  @override
  List<Object> get props => [items];
}
