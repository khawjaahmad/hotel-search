// test/unit/features/favorites/domain/usecases/remove_favorite_usecase_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hotel_booking/features/favorites/domain/repositories/repositores.dart';
import 'package:hotel_booking/features/favorites/domain/usecases/usecases.dart';
import 'package:hotel_booking/features/hotels/domain/entities/entities.dart';

class MockFavoritesRepository extends Mock implements FavoritesRepository {}

void main() {
  group('RemoveFavoriteUseCase', () {
    late RemoveFavoriteUseCase useCase;
    late MockFavoritesRepository mockRepository;
    late Hotel testHotel;

    setUp(() {
      mockRepository = MockFavoritesRepository();
      useCase = RemoveFavoriteUseCase(favoritesRepository: mockRepository);
      testHotel = const Hotel(
        name: 'Test Hotel',
        location: Location(latitude: 40.7128, longitude: -74.0060),
        description: 'A test hotel',
      );
    });

    test('should call repository removeFavorite method', () {
      // Act
      useCase.call(testHotel);

      // Assert
      verify(() => mockRepository.removeFavorite(testHotel)).called(1);
    });

    test('should handle multiple consecutive calls', () {
      // Arrange
      const anotherHotel = Hotel(
        name: 'Another Hotel',
        location: Location(latitude: 41.8781, longitude: -87.6298),
      );

      // Act
      useCase.call(testHotel);
      useCase.call(anotherHotel);

      // Assert
      verify(() => mockRepository.removeFavorite(testHotel)).called(1);
      verify(() => mockRepository.removeFavorite(anotherHotel)).called(1);
    });

    test('should pass the exact hotel object to repository', () {
      // Act
      useCase.call(testHotel);

      // Assert
      verify(() => mockRepository.removeFavorite(testHotel)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}

