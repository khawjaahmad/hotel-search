import 'package:hotel_booking/core/models/models.dart';
import 'package:hotel_booking/features/hotels/domain/entities/entities.dart';

abstract class HotelsRepository {
  Future<PaginatedResponse<Hotel>> fetchHotels({
    required SearchParams params,
    String? pageToken,
  });
}
