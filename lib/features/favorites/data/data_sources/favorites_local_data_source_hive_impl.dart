import 'dart:async';

import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

import 'package:hotel_booking/features/favorites/data/data_sources/data_sources.dart';
import 'package:hotel_booking/features/favorites/data/mappers/mappers.dart';
import 'package:hotel_booking/features/favorites/data/models/models.dart';
import 'package:hotel_booking/features/hotels/domain/entities/entities.dart';

@Singleton(as: FavoritesLocalDataSource)
class FavoritesLocalDataSourceHiveImpl implements FavoritesLocalDataSource {
  final Box _box = Hive.box(name: 'favorite_hotels');
  final _streamController = StreamController<List<Hotel>>.broadcast();

  FavoritesLocalDataSourceHiveImpl() {
    _box.watch().listen((_) {
      _streamController.add(getFavorites());
    });
  }

  @override
  List<Hotel> getFavorites() {
    return _box.getRange(0, _box.length).map((e) {
      return HiveHotel.fromJson(e).toEntity();
    }).toList();
  }

  @override
  Stream<List<Hotel>> watchFavorites() {
    return _streamController.stream;
  }

  @override
  bool isFavorite(Hotel hotel) {
    return _box.containsKey(hotel.location.decimalDegrees);
  }

  @override
  void addFavorite(Hotel hotel) {
    _box.put(
      hotel.location.decimalDegrees,
      hotel.toHiveModel().toJson(),
    );
  }

  @override
  void removeFavorite(Hotel hotel) {
    _box.delete(hotel.location.decimalDegrees);
  }
}
