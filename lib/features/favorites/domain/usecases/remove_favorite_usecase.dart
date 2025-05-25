import 'package:injectable/injectable.dart';

import 'package:hotel_booking/features/favorites/domain/repositories/repositores.dart';
import 'package:hotel_booking/features/hotels/domain/entities/entities.dart';

@lazySingleton
class RemoveFavoriteUseCase {
  final FavoritesRepository _favoritesRepository;

  RemoveFavoriteUseCase({
    required FavoritesRepository favoritesRepository,
  }) : _favoritesRepository = favoritesRepository;

  void call(Hotel hotel) {
    _favoritesRepository.removeFavorite(hotel);
  }
}
