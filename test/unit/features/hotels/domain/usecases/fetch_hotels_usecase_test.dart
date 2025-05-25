
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hotel_booking/core/models/models.dart';
import 'package:hotel_booking/features/hotels/domain/entities/entities.dart';
import 'package:hotel_booking/features/hotels/domain/repositories/repositories.dart';
import 'package:hotel_booking/features/hotels/domain/usecases/usecases.dart';

class MockHotelsRepository with Mock implements HotelsRepository {}

void main() {
  group('FetchHotelsUseCase', () {
    late FetchHotelsUseCase useCase;
    late MockHotelsRepository mockRepository;

    final testParams = SearchParams(
      query: 'New York',
      checkInDate: DateTime(2024, 1, 15),
      checkOutDate: DateTime(2024, 1, 17),
    );

    setUpAll(() {
      // Register fallback values for any() matchers
      registerFallbackValue(SearchParams(
        query: 'fallback',
        checkInDate: DateTime(2024, 1, 1),
        checkOutDate: DateTime(2024, 1, 2),
      ));
    });

    setUp(() {
      mockRepository = MockHotelsRepository();
      useCase = FetchHotelsUseCase(hotelsRepository: mockRepository);
    });

    test('should return paginated response from repository', () async {
      // Arrange
      const expectedHotels = [
        Hotel(
          name: 'Hotel 1',
          location: Location(latitude: 40.7128, longitude: -74.0060),
        ),
        Hotel(
          name: 'Hotel 2',
          location: Location(latitude: 40.7589, longitude: -73.9851),
        ),
      ];
      const expectedResponse = PaginatedResponse<Hotel>(
        items: expectedHotels,
        nextPageToken: 'next_page_token',
      );

      when(() => mockRepository.fetchHotels(
            params: testParams,
            pageToken: null,
          )).thenAnswer((_) async => expectedResponse);

      // Act
      final result = await useCase.call(params: testParams);

      // Assert
      expect(result, equals(expectedResponse));
      verify(() => mockRepository.fetchHotels(
            params: testParams,
            pageToken: null,
          )).called(1);
    });

    test('should propagate exception from repository', () async {
      // Arrange
      final exception = Exception('Network error');
      when(() => mockRepository.fetchHotels(
            params: any(named: 'params'),
            pageToken: any(named: 'pageToken'),
          )).thenThrow(exception);

      // Act & Assert
      expect(
        () async => await useCase.call(params: testParams),
        throwsA(equals(exception)),
      );
    });
  });
}
