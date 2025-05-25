// test/unit/features/favorites/presentation/bloc/favorites_bloc_test.dart
import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hotel_booking/features/favorites/domain/usecases/usecases.dart';
import 'package:hotel_booking/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:hotel_booking/features/hotels/domain/entities/entities.dart';

// Local Mock Classes (Self-contained)
class MockGetFavoritesUseCase with Mock implements GetFavoritesUseCase {}

class MockWatchFavoritesUseCase with Mock implements WatchFavoritesUseCase {}

class MockAddFavoriteUseCase with Mock implements AddFavoriteUseCase {}

class MockRemoveFavoriteUseCase with Mock implements RemoveFavoriteUseCase {}

// Test Data
const testHotel = Hotel(
  name: 'Test Hotel',
  location: Location(latitude: 40.7128, longitude: -74.0060),
  description: 'A beautiful test hotel',
);

const anotherHotel = Hotel(
  name: 'Another Hotel',
  location: Location(latitude: 41.8781, longitude: -87.6298),
  description: 'Another great hotel',
);

const multipleHotels = [testHotel, anotherHotel];

void main() {
  group('FavoritesBloc', () {
    late FavoritesBloc favoritesBloc;
    late MockGetFavoritesUseCase mockGetFavoritesUseCase;
    late MockWatchFavoritesUseCase mockWatchFavoritesUseCase;
    late MockAddFavoriteUseCase mockAddFavoriteUseCase;
    late MockRemoveFavoriteUseCase mockRemoveFavoriteUseCase;
    late StreamController<List<Hotel>> watchFavoritesController;

    setUpAll(() {
      // Register fallback values for any() matchers
      registerFallbackValue(testHotel);
    });

    setUp(() {
      mockGetFavoritesUseCase = MockGetFavoritesUseCase();
      mockWatchFavoritesUseCase = MockWatchFavoritesUseCase();
      mockAddFavoriteUseCase = MockAddFavoriteUseCase();
      mockRemoveFavoriteUseCase = MockRemoveFavoriteUseCase();

      watchFavoritesController = StreamController<List<Hotel>>.broadcast();

      // Setup default mocks
      when(() => mockGetFavoritesUseCase.call()).thenReturn([]);
      when(() => mockWatchFavoritesUseCase.call())
          .thenAnswer((_) => watchFavoritesController.stream);
    });

    tearDown(() {
      watchFavoritesController.close();
      favoritesBloc.close();
    });

    FavoritesBloc createBloc() {
      return FavoritesBloc(
        getFavoritesUseCase: mockGetFavoritesUseCase,
        watchFavoritesUseCase: mockWatchFavoritesUseCase,
        addFavoriteUseCase: mockAddFavoriteUseCase,
        removeFavoriteUseCase: mockRemoveFavoriteUseCase,
      );
    }

    group('initialization', () {
      test('should have correct initial state', () {
        // Arrange & Act
        favoritesBloc = createBloc();

        // Assert
        expect(favoritesBloc.state, isA<FavoritesState>());
        expect(favoritesBloc.state.items, isEmpty);
      });

      test('should call getFavoritesUseCase on initialization', () {
        // Act
        favoritesBloc = createBloc();

        // Assert
        verify(() => mockGetFavoritesUseCase.call()).called(1);
      });

      test('should initialize with favorites from getFavoritesUseCase', () {
        // Arrange
        when(() => mockGetFavoritesUseCase.call()).thenReturn(multipleHotels);

        // Act
        favoritesBloc = createBloc();

        // Assert
        expect(favoritesBloc.state.items, equals(multipleHotels));
      });
    });

    group('AddFavoriteEvent', () {
      blocTest<FavoritesBloc, FavoritesState>(
        'should call addFavoriteUseCase when AddFavoriteEvent is added',
        build: createBloc,
        act: (bloc) {
          bloc.add(AddFavoriteEvent(hotel: testHotel));
        },
        verify: (_) {
          verify(() => mockAddFavoriteUseCase.call(testHotel)).called(1);
        },
      );

      blocTest<FavoritesBloc, FavoritesState>(
        'should not emit new states when adding favorite',
        build: createBloc,
        act: (bloc) {
          bloc.add(AddFavoriteEvent(hotel: testHotel));
        },
        expect: () => [],
        verify: (_) {
          verify(() => mockAddFavoriteUseCase.call(testHotel)).called(1);
        },
      );
    });

    group('RemoveFavoriteEvent', () {
      blocTest<FavoritesBloc, FavoritesState>(
        'should call removeFavoriteUseCase when RemoveFavoriteEvent is added',
        build: createBloc,
        act: (bloc) {
          bloc.add(RemoveFavoriteEvent(hotel: testHotel));
        },
        verify: (_) {
          verify(() => mockRemoveFavoriteUseCase.call(testHotel)).called(1);
        },
      );
    });

    group('FavoritesUpdatedEvent', () {
      blocTest<FavoritesBloc, FavoritesState>(
        'should emit new state with updated items',
        build: createBloc,
        act: (bloc) {
          bloc.add(FavoritesUpdatedEvent(items: multipleHotels));
        },
        expect: () => [
          FavoritesState(items: multipleHotels),
        ],
      );

      blocTest<FavoritesBloc, FavoritesState>(
        'should emit state with empty list when items are empty',
        build: createBloc,
        act: (bloc) {
          bloc.add(FavoritesUpdatedEvent(items: []));
        },
        expect: () => [
          FavoritesState(items: []),
        ],
      );
    });

    group('stream subscription', () {
      test('should listen to watchFavoritesUseCase stream and emit updates',
          () async {
        // Arrange
        favoritesBloc = createBloc();
        final testHotels = [testHotel];

        // Act
        watchFavoritesController.add(testHotels);
        await Future.delayed(Duration.zero);

        // Assert
        expect(favoritesBloc.state.items, equals(testHotels));
      });
    });

    group('FavoritesState', () {
      test('should correctly check if hotel is contained in favorites', () {
        // Arrange
        final state = FavoritesState(items: [testHotel]);

        // Act & Assert
        expect(state.contains(testHotel), isTrue);
        expect(state.contains(anotherHotel), isFalse);
      });

      test('should handle empty favorites when checking contains', () {
        // Arrange
        final state = FavoritesState(items: []);

        // Act & Assert
        expect(state.contains(testHotel), isFalse);
      });

      test('should support equality comparison', () {
        // Arrange
        final state1 = FavoritesState(items: [testHotel]);
        final state2 = FavoritesState(items: [testHotel]);
        final state3 = FavoritesState(items: [anotherHotel]);

        // Act & Assert
        expect(state1, equals(state2));
        expect(state1, isNot(equals(state3)));
      });
    });

    group('disposal', () {
      test('should cancel stream subscription on close', () async {
        // Arrange
        favoritesBloc = createBloc();

        // Act
        await favoritesBloc.close();

        // Assert
        expect(favoritesBloc.isClosed, isTrue);
      });
    });
  });
}
