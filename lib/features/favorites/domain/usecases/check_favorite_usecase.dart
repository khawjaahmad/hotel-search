import 'package:injectable/injectable.dart';

import 'package:hotel_booking/features/favorites/domain/repositories/repositores.dart';
import 'package:hotel_booking/features/hotels/domain/entities/entities.dart';

@lazySingleton
class CheckFavoriteUseCase {
  final FavoritesRepository _favoritesRepository;

  CheckFavoriteUseCase({
    required FavoritesRepository favoritesRepository,
  }) : _favoritesRepository = favoritesRepository;

  bool call(Hotel hotel) {
    return _favoritesRepository.isFavorite(hotel);
  }
}
