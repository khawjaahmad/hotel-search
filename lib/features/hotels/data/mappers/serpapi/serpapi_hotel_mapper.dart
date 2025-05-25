import 'package:hotel_booking/features/hotels/data/models/models.dart';
import 'package:hotel_booking/features/hotels/domain/entities/entities.dart';

import 'serpapi_location_mapper.dart';

extension SerpapiHotelMapper on SerpapiProperty {
  Hotel toEntity() {
    return Hotel(
      name: name,
      location: gpsCoordinates.toEntity(),
      description: description,
    );
  }
}
