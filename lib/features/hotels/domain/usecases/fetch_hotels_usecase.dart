import 'package:injectable/injectable.dart';

import 'package:hotel_booking/core/models/models.dart';
import 'package:hotel_booking/features/hotels/domain/entities/entities.dart';
import 'package:hotel_booking/features/hotels/domain/repositories/repositories.dart';

@lazySingleton
class FetchHotelsUseCase {
  final HotelsRepository _hotelsRepository;

  FetchHotelsUseCase({
    required HotelsRepository hotelsRepository,
  }) : _hotelsRepository = hotelsRepository;

  Future<PaginatedResponse<Hotel>> call({
    required SearchParams params,
    String? pageToken,
  }) {
    return _hotelsRepository.fetchHotels(
      params: params,
      pageToken: pageToken,
    );
  }
}
