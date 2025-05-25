import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hotel_booking/features/favorites/domain/repositories/repositores.dart';
import 'package:hotel_booking/features/favorites/domain/usecases/usecases.dart';
import 'package:hotel_booking/features/hotels/domain/entities/entities.dart';

class MockFavoritesRepository extends Mock implements FavoritesRepository {}

void main() {
  group('WatchFavoritesUseCase', () {
    late WatchFavoritesUseCase useCase;
    late MockFavoritesRepository mockRepository;

    setUp(() {
      mockRepository = MockFavoritesRepository();
      useCase = WatchFavoritesUseCase(favoritesRepository: mockRepository);
    });

    test('should return stream of favorite hotels from repository', () {
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
      when(() => mockRepository.watchFavorites())
          .thenAnswer((_) => Stream.value(expectedHotels));

      // Act
      final result = useCase.call();

      // Assert
      expect(result, emits(expectedHotels));
      verify(() => mockRepository.watchFavorites()).called(1);
    });

    test('should return stream that emits empty list when no favorites', () {
      // Arrange
      when(() => mockRepository.watchFavorites())
          .thenAnswer((_) => Stream.value([]));

      // Act
      final result = useCase.call();

      // Assert
      expect(result, emits(isEmpty));
      verify(() => mockRepository.watchFavorites()).called(1);
    });

    test('should return stream that emits multiple updates', () async {
      // Arrange
      const hotel1 = Hotel(
        name: 'Hotel 1',
        location: Location(latitude: 40.7128, longitude: -74.0060),
      );
      const hotel2 = Hotel(
        name: 'Hotel 2',
        location: Location(latitude: 41.8781, longitude: -87.6298),
      );

      when(() => mockRepository.watchFavorites()).thenAnswer(
        (_) => Stream.fromIterable([
          [],
          [hotel1],
          [hotel1, hotel2],
          [hotel2],
        ]),
      );

      // Act
      final result = useCase.call();

      // Assert
      expect(
        result,
        emitsInOrder([
          isEmpty,
          [hotel1],
          [hotel1, hotel2],
          [hotel2],
        ]),
      );
      verify(() => mockRepository.watchFavorites()).called(1);
    });

    test('should handle error in stream', () {
      // Arrange
      final error = Exception('Failed to watch favorites');
      when(() => mockRepository.watchFavorites())
          .thenAnswer((_) => Stream.error(error));

      // Act
      final result = useCase.call();

      // Assert
      expect(result, emitsError(error));
      verify(() => mockRepository.watchFavorites()).called(1);
    });

    test('should call repository method only once per call', () {
      // Arrange
      when(() => mockRepository.watchFavorites())
          .thenAnswer((_) => Stream.value([]));

      // Act
      useCase.call();
      useCase.call();

      // Assert
      verify(() => mockRepository.watchFavorites()).called(2);
    });
  });
}
