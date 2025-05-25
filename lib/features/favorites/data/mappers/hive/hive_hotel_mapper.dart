import 'package:hotel_booking/features/favorites/data/models/models.dart';
import 'package:hotel_booking/features/favorites/data/mappers/mappers.dart';
import 'package:hotel_booking/features/hotels/domain/entities/entities.dart';

extension HiveHotelMapper on HiveHotel {
  Hotel toEntity() {
    return Hotel(
      name: name,
      location: location.toEntity(),
      description: description,
    );
  }
}

extension HotelHiveMapper on Hotel {
  HiveHotel toHiveModel() {
    return HiveHotel(
      name: name,
      location: location.toHiveModel(),
      description: description,
    );
  }
}
