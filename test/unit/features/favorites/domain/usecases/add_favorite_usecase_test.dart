import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hotel_booking/features/favorites/domain/repositories/repositores.dart';
import 'package:hotel_booking/features/favorites/domain/usecases/usecases.dart';
import 'package:hotel_booking/features/hotels/domain/entities/entities.dart';

class MockFavoritesRepository with Mock implements FavoritesRepository {}

void main() {
  group('AddFavoriteUseCase', () {
    late AddFavoriteUseCase useCase;
    late MockFavoritesRepository mockRepository;

    const testHotel = Hotel(
      name: 'Test Hotel',
      location: Location(latitude: 40.7128, longitude: -74.0060),
      description: 'A test hotel',
    );

    setUp(() {
      mockRepository = MockFavoritesRepository();
      useCase = AddFavoriteUseCase(favoritesRepository: mockRepository);
    });

    test('should call repository addFavorite method', () {
      // Act
      useCase.call(testHotel);

      // Assert
      verify(() => mockRepository.addFavorite(testHotel)).called(1);
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
      verify(() => mockRepository.addFavorite(testHotel)).called(1);
      verify(() => mockRepository.addFavorite(anotherHotel)).called(1);
    });
  });
}

