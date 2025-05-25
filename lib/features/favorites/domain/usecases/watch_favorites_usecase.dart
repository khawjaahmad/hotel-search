import 'package:injectable/injectable.dart';

import 'package:hotel_booking/features/favorites/domain/repositories/repositores.dart';
import 'package:hotel_booking/features/hotels/domain/entities/entities.dart';

@lazySingleton
class WatchFavoritesUseCase {
  final FavoritesRepository _favoritesRepository;

  WatchFavoritesUseCase({
    required FavoritesRepository favoritesRepository,
  }) : _favoritesRepository = favoritesRepository;

  Stream<List<Hotel>> call() {
    return _favoritesRepository.watchFavorites();
  }
}
