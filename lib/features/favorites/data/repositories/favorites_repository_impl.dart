import 'package:injectable/injectable.dart';

import 'package:hotel_booking/features/favorites/data/data_sources/data_sources.dart';
import 'package:hotel_booking/features/favorites/domain/repositories/repositores.dart';
import 'package:hotel_booking/features/hotels/domain/entities/entities.dart';

@Singleton(as: FavoritesRepository)
class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesLocalDataSource _favoritesLocalDataSource;

  FavoritesRepositoryImpl({
    required FavoritesLocalDataSource favoritesLocalDataSource,
  }) : _favoritesLocalDataSource = favoritesLocalDataSource;

  @override
  List<Hotel> getFavorites() {
    return _favoritesLocalDataSource.getFavorites();
  }

  @override
  Stream<List<Hotel>> watchFavorites() {
    return _favoritesLocalDataSource.watchFavorites();
  }

  @override
  bool isFavorite(Hotel hotel) {
    return _favoritesLocalDataSource.isFavorite(hotel);
  }

  @override
  void addFavorite(Hotel hotel) {
    _favoritesLocalDataSource.addFavorite(hotel);
  }

  @override
  void removeFavorite(Hotel hotel) {
    _favoritesLocalDataSource.removeFavorite(hotel);
  }
}
