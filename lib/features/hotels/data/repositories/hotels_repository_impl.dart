import 'package:injectable/injectable.dart';

import 'package:hotel_booking/core/models/models.dart';
import 'package:hotel_booking/features/hotels/data/data_sources/data_sources.dart';
import 'package:hotel_booking/features/hotels/domain/entities/entities.dart';
import 'package:hotel_booking/features/hotels/domain/repositories/repositories.dart';

@Singleton(as: HotelsRepository)
class HotelsRepositoryImpl implements HotelsRepository {
  final HotelsRemoteDataSource _hotelsRemoteDataSource;

  HotelsRepositoryImpl({
    required HotelsRemoteDataSource hotelsRemoteDataSource,
  }) : _hotelsRemoteDataSource = hotelsRemoteDataSource;

  @override
  Future<PaginatedResponse<Hotel>> fetchHotels({
    required SearchParams params,
    String? pageToken,
  }) {
    return _hotelsRemoteDataSource.fetchHotels(
      params: params,
      pageToken: pageToken,
    );
  }
}
