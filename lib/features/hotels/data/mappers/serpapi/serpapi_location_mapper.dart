import 'package:hotel_booking/features/hotels/data/models/models.dart';
import 'package:hotel_booking/features/hotels/domain/entities/entities.dart';

extension SerpapiLocationMapper on SerpapiGpsCoordinates {
  Location toEntity() {
    return Location(
      latitude: latitude,
      longitude: longitude,
    );
  }
}
