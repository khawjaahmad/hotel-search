// test/unit/features/favorites/domain/usecases/check_favorite_usecase_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hotel_booking/features/favorites/domain/repositories/repositores.dart';
import 'package:hotel_booking/features/favorites/domain/usecases/usecases.dart';
import 'package:hotel_booking/features/hotels/domain/entities/entities.dart';

class MockFavoritesRepository extends Mock implements FavoritesRepository {}

void main() {
  group('CheckFavoriteUseCase', () {
    late CheckFavoriteUseCase useCase;
    late MockFavoritesRepository mockRepository;
    late Hotel testHotel;

    setUp(() {
      mockRepository = MockFavoritesRepository();
      useCase = CheckFavoriteUseCase(favoritesRepository: mockRepository);
      testHotel = const Hotel(
        name: 'Test Hotel',
        location: Location(latitude: 40.7128, longitude: -74.0060),
        description: 'A test hotel',
      );
    });

    test('should return true when hotel is favorite', () {
      // Arrange
      when(() => mockRepository.isFavorite(testHotel)).thenReturn(true);

      // Act
      final result = useCase.call(testHotel);

      // Assert
      expect(result, isTrue);
      verify(() => mockRepository.isFavorite(testHotel)).called(1);
    });

    test('should return false when hotel is not favorite', () {
      // Arrange
      when(() => mockRepository.isFavorite(testHotel)).thenReturn(false);

      // Act
      final result = useCase.call(testHotel);

      // Assert
      expect(result, isFalse);
      verify(() => mockRepository.isFavorite(testHotel)).called(1);
    });

    test('should pass the exact hotel object to repository', () {
      // Arrange
      when(() => mockRepository.isFavorite(testHotel)).thenReturn(true);

      // Act
      useCase.call(testHotel);

      // Assert
      verify(() => mockRepository.isFavorite(testHotel)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should handle multiple calls with different hotels', () {
      // Arrange
      const anotherHotel = Hotel(
        name: 'Another Hotel',
        location: Location(latitude: 41.8781, longitude: -87.6298),
      );
      when(() => mockRepository.isFavorite(testHotel)).thenReturn(true);
      when(() => mockRepository.isFavorite(anotherHotel)).thenReturn(false);

      // Act
      final result1 = useCase.call(testHotel);
      final result2 = useCase.call(anotherHotel);

      // Assert
      expect(result1, isTrue);
      expect(result2, isFalse);
      verify(() => mockRepository.isFavorite(testHotel)).called(1);
      verify(() => mockRepository.isFavorite(anotherHotel)).called(1);
    });
  });
}
