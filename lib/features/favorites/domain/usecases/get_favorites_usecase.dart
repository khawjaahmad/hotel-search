import 'package:injectable/injectable.dart';

import 'package:hotel_booking/features/favorites/domain/repositories/repositores.dart';
import 'package:hotel_booking/features/hotels/domain/entities/entities.dart';

@lazySingleton
class GetFavoritesUseCase {
  final FavoritesRepository _favoritesRepository;

  GetFavoritesUseCase({
    required FavoritesRepository favoritesRepository,
  }) : _favoritesRepository = favoritesRepository;

  List<Hotel> call() {
    return _favoritesRepository.getFavorites();
  }
}
