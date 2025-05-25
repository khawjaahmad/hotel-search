
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hotel_booking/features/favorites/domain/repositories/repositores.dart';
import 'package:hotel_booking/features/favorites/domain/usecases/usecases.dart';
import 'package:hotel_booking/features/hotels/domain/entities/entities.dart';

class MockFavoritesRepository with Mock implements FavoritesRepository {}

void main() {
  group('GetFavoritesUseCase', () {
    late GetFavoritesUseCase useCase;
    late MockFavoritesRepository mockRepository;

    setUp(() {
      mockRepository = MockFavoritesRepository();
      useCase = GetFavoritesUseCase(favoritesRepository: mockRepository);
    });

    test('should return list of favorite hotels from repository', () {
      // Arrange
      const expectedHotels = [
        Hotel(
          name: 'Hotel 1',
          location: Location(latitude: 40.7128, longitude: -74.0060),
        ),
        Hotel(
          name: 'Hotel 2',
          location: Location(latitude: 41.8781, longitude: -87.6298),
        ),
      ];
      when(() => mockRepository.getFavorites()).thenReturn(expectedHotels);

      // Act
      final result = useCase.call();

      // Assert
      expect(result, equals(expectedHotels));
      verify(() => mockRepository.getFavorites()).called(1);
    });

    test('should return empty list when no favorites exist', () {
      // Arrange
      when(() => mockRepository.getFavorites()).thenReturn([]);

      // Act
      final result = useCase.call();

      // Assert
      expect(result, isEmpty);
      verify(() => mockRepository.getFavorites()).called(1);
    });
  });
}