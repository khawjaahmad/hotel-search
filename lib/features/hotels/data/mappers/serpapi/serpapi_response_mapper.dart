import 'package:hotel_booking/core/models/models.dart';
import 'package:hotel_booking/features/hotels/data/models/models.dart';
import 'package:hotel_booking/features/hotels/domain/entities/entities.dart';

import 'serpapi_hotel_mapper.dart';

extension SerpapiResponseMapper on SerpapiResponse {
  PaginatedResponse<Hotel> toEntity() {
    return PaginatedResponse(
      items: properties.map((e) => e.toEntity()).toList(),
      nextPageToken: pagination.nextPageToken,
    );
  }
}
