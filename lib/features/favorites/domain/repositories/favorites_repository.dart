import 'package:hotel_booking/features/hotels/domain/entities/entities.dart';

abstract class FavoritesRepository {
  List<Hotel> getFavorites();
  Stream<List<Hotel>> watchFavorites();
  bool isFavorite(Hotel hotel);
  void addFavorite(Hotel hotel);
  void removeFavorite(Hotel hotel);
}
