import 'package:hotel_booking/features/favorites/data/models/models.dart';
import 'package:hotel_booking/features/hotels/domain/entities/entities.dart';

extension HiveLocationMapper on HiveLocation {
  Location toEntity() {
    return Location(
      latitude: latitude,
      longitude: longitude,
    );
  }
}

extension LocationHiveMapper on Location {
  HiveLocation toHiveModel() {
    return HiveLocation(
      latitude: latitude,
      longitude: longitude,
    );
  }
}
