import 'package:injectable/injectable.dart';

import 'package:hotel_booking/features/favorites/domain/repositories/repositores.dart';
import 'package:hotel_booking/features/hotels/domain/entities/entities.dart';

@lazySingleton
class AddFavoriteUseCase {
  final FavoritesRepository _favoritesRepository;

  AddFavoriteUseCase({
    required FavoritesRepository favoritesRepository,
  }) : _favoritesRepository = favoritesRepository;

  void call(Hotel hotel) {
    _favoritesRepository.addFavorite(hotel);
  }
}
