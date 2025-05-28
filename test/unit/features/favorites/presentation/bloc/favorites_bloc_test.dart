// test/unit/features/favorites/presentation/bloc/favorites_bloc_test.dart
import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_booking/features/favorites/domain/usecases/usecases.dart';
import 'package:hotel_booking/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:hotel_booking/features/hotels/domain/entities/entities.dart';
import 'package:mocktail/mocktail.dart';

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
      registerFallbackValue(testHotel);
    });

    setUp(() {
      mockGetFavoritesUseCase = MockGetFavoritesUseCase();
      mockWatchFavoritesUseCase = MockWatchFavoritesUseCase();
      mockAddFavoriteUseCase = MockAddFavoriteUseCase();
      mockRemoveFavoriteUseCase = MockRemoveFavoriteUseCase();

      watchFavoritesController = StreamController<List<Hotel>>.broadcast();

      when(() => mockGetFavoritesUseCase.call()).thenReturn([]);
      when(() => mockWatchFavoritesUseCase.call())
          .thenAnswer((_) => watchFavoritesController.stream);
      when(() => mockAddFavoriteUseCase.call(any())).thenAnswer((_) async {});
      when(() => mockRemoveFavoriteUseCase.call(any()))
          .thenAnswer((_) async {});
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
        favoritesBloc = createBloc();
        expect(favoritesBloc.state, isA<FavoritesState>());
        expect(favoritesBloc.state.items, isEmpty);
      });

      test('should call getFavoritesUseCase on initialization', () {
        favoritesBloc = createBloc();
        verify(() => mockGetFavoritesUseCase.call()).called(1);
      });

      blocTest<FavoritesBloc, FavoritesState>(
        'should initialize with favorites from getFavoritesUseCase',
        setUp: () {
          when(() => mockGetFavoritesUseCase.call()).thenReturn(multipleHotels);
        },
        build: createBloc,
        expect: () => [
          FavoritesState(items: multipleHotels),
        ],
      );
    });

    group('FavoritesEvents', () {
      blocTest<FavoritesBloc, FavoritesState>(
        'should emit new state when FavoritesUpdatedEvent is added',
        build: createBloc,
        seed: () => FavoritesState(items: []), // Set initial state
        act: (bloc) => bloc.add(FavoritesUpdatedEvent(items: multipleHotels)),
        expect: () => [
          FavoritesState(items: multipleHotels),
        ],
      );

      blocTest<FavoritesBloc, FavoritesState>(
        'should handle AddFavoriteEvent',
        build: createBloc,
        act: (bloc) => bloc.add(const AddFavoriteEvent(hotel: testHotel)),
        verify: (_) {
          verify(() => mockAddFavoriteUseCase.call(testHotel)).called(1);
        },
      );

      blocTest<FavoritesBloc, FavoritesState>(
        'should handle RemoveFavoriteEvent',
        build: createBloc,
        act: (bloc) => bloc.add(const RemoveFavoriteEvent(hotel: testHotel)),
        verify: (_) {
          verify(() => mockRemoveFavoriteUseCase.call(testHotel)).called(1);
        },
      );

      test('should handle stream updates from watchFavoritesUseCase', () async {
        favoritesBloc = createBloc();

        // Simulate stream updates
        watchFavoritesController.add(multipleHotels);
        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(favoritesBloc.state.items, equals(multipleHotels));
      });
    });

    group('Events equality', () {
      test('FavoritesUpdatedEvent props should contain items', () {
        final event = FavoritesUpdatedEvent(items: multipleHotels);
        expect(event.props, [multipleHotels]);
      });

      test('AddFavoriteEvent props should contain hotel', () {
        const event = AddFavoriteEvent(hotel: testHotel);
        expect(event.props, [testHotel]);
      });

      test('RemoveFavoriteEvent props should contain hotel', () {
        const event = RemoveFavoriteEvent(hotel: testHotel);
        expect(event.props, [testHotel]);
      });
    });

    group('State tests', () {
      test('FavoritesState should maintain items', () {
        final state = FavoritesState(items: multipleHotels);
        expect(state.items, multipleHotels);
      });

      test('FavoritesState props should contain items', () {
        final state = FavoritesState(items: multipleHotels);
        expect(state.props, [multipleHotels]);
      });

      test('Different FavoritesStates with same items should be equal', () {
        final state1 = FavoritesState(items: multipleHotels);
        final state2 = FavoritesState(items: multipleHotels);
        expect(state1, equals(state2));
      });
    });
  });
}
