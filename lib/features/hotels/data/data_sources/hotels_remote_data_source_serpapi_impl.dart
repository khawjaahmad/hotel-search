import 'package:injectable/injectable.dart';

import 'package:hotel_booking/core/models/models.dart';
import 'package:hotel_booking/core/network/network.dart';
import 'package:hotel_booking/env.dart';
import 'package:hotel_booking/features/hotels/data/mappers/mappers.dart';
import 'package:hotel_booking/features/hotels/data/models/models.dart';
import 'package:hotel_booking/features/hotels/domain/entities/entities.dart';

import 'hotels_remote_data_source.dart';

@Singleton(as: HotelsRemoteDataSource)
class HotelsRemoteDataSourceSerpapiImpl implements HotelsRemoteDataSource {
  final ApiClient _apiClient;

  HotelsRemoteDataSourceSerpapiImpl({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  @override
  Future<PaginatedResponse<Hotel>> fetchHotels({
    required SearchParams params,
    String? pageToken,
  }) async {
    final json = await _apiClient.get(
      'serpapi.com',
      'search.json',
      queryParameters: {
        'api_key': Env.serpapiApiKey,
        if (pageToken != null) 'next_page_token': pageToken,
        'engine': 'google_hotels',
        'q': params.query,
        'check_in_date': params.checkInDate.toString().substring(0, 10),
        'check_out_date': params.checkOutDate.toString().substring(0, 10),
      },
    );
    return SerpapiResponse.fromJson(json).toEntity();
  }
}
