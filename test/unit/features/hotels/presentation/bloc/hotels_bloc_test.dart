// test/unit/features/hotels/presentation/bloc/hotels_bloc_test.dart
import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hotel_booking/core/models/models.dart';
import 'package:hotel_booking/features/hotels/domain/entities/entities.dart';
import 'package:hotel_booking/features/hotels/domain/usecases/usecases.dart';
import 'package:hotel_booking/features/hotels/presentation/bloc/hotels_bloc.dart';

// Local Mock Classes (Self-contained)
class MockFetchHotelsUseCase with Mock implements FetchHotelsUseCase {}

// Test Data (Self-contained)
final defaultSearchParams = SearchParams(
  query: 'New York',
  checkInDate: DateTime(2024, 6, 15),
  checkOutDate: DateTime(2024, 6, 17),
);

final emptyQuerySearchParams = SearchParams(
  query: '',
  checkInDate: DateTime(2024, 6, 15),
  checkOutDate: DateTime(2024, 6, 17),
);

const defaultHotel = Hotel(
  name: 'Test Hotel',
  location: Location(latitude: 40.7128, longitude: -74.0060),
  description: 'A beautiful test hotel',
);

const anotherHotel = Hotel(
  name: 'Another Hotel',
  location: Location(latitude: 41.8781, longitude: -87.6298),
  description: 'Another great hotel',
);

const firstPageResponse = PaginatedResponse<Hotel>(
  items: [defaultHotel, anotherHotel],
  nextPageToken: 'page_2_token',
);

const lastPageResponse = PaginatedResponse<Hotel>(
  items: [
    Hotel(
      name: 'Last Hotel',
      location: Location(latitude: 34.0522, longitude: -118.2437),
    ),
  ],
  nextPageToken: null,
);

const emptyResponse = PaginatedResponse<Hotel>(
  items: [],
  nextPageToken: null,
);

SearchParams createSearchParams({String? query}) {
  return SearchParams(
    query: query ?? 'Default Query',
    checkInDate: DateTime(2024, 6, 15),
    checkOutDate: DateTime(2024, 6, 17),
  );
}

void main() {
  group('HotelsBloc', () {
    late HotelsBloc hotelsBloc;
    late MockFetchHotelsUseCase mockFetchHotelsUseCase;

    setUpAll(() {
      // Register fallback values for any() matchers
      registerFallbackValue(SearchParams(
        query: 'fallback',
        checkInDate: DateTime(2024, 1, 1),
        checkOutDate: DateTime(2024, 1, 2),
      ));
    });

    setUp(() {
      mockFetchHotelsUseCase = MockFetchHotelsUseCase();
    });

    tearDown(() {
      hotelsBloc.close();
    });

    HotelsBloc createBloc() {
      return HotelsBloc(fetchHotelsUseCase: mockFetchHotelsUseCase);
    }

    group('initialization', () {
      test('should have correct initial state', () {
        // Act
        hotelsBloc = createBloc();

        // Assert
        expect(hotelsBloc.state, isA<HotelsState>());
        expect(hotelsBloc.state.loading, isFalse);
        expect(hotelsBloc.state.items, isEmpty);
        expect(hotelsBloc.state.params.query, isEmpty);
        expect(hotelsBloc.state.nextPageToken, isNull);
        expect(hotelsBloc.state.error, isNull);
        expect(hotelsBloc.state.hasReachedMax, isFalse);
        expect(hotelsBloc.state.hasError, isFalse);
      });

      test('should have valid date range in initial params', () {
        // Act
        hotelsBloc = createBloc();

        // Assert
        final params = hotelsBloc.state.params;
        expect(
            params.checkInDate.isBefore(params.checkOutDate) ||
                params.checkInDate.isAtSameMomentAs(params.checkOutDate),
            isTrue);
      });
    });

    group('HotelsSearchUpdateEvent', () {
      blocTest<HotelsBloc, HotelsState>(
        'should emit new state with updated params when query is empty',
        build: createBloc,
        act: (bloc) {
          bloc.add(HotelsSearchUpdateEvent(params: emptyQuerySearchParams));
        },
        wait: const Duration(milliseconds: 600), // Wait for debounce
        expect: () => [
          HotelsState(params: emptyQuerySearchParams),
        ],
      );

      blocTest<HotelsBloc, HotelsState>(
        'should emit new state and trigger fetch when query is not empty',
        build: createBloc,
        setUp: () {
          when(() => mockFetchHotelsUseCase.call(
                params: any(named: 'params'),
                pageToken: any(named: 'pageToken'),
              )).thenAnswer((_) async => firstPageResponse);
        },
        act: (bloc) {
          bloc.add(HotelsSearchUpdateEvent(params: defaultSearchParams));
        },
        wait: const Duration(milliseconds: 700), // Wait for debounce + fetch
        expect: () => [
          HotelsState(params: defaultSearchParams),
          HotelsState(
            params: defaultSearchParams,
            loading: true,
          ),
          HotelsState(
            params: defaultSearchParams,
            items: firstPageResponse.items,
            nextPageToken: firstPageResponse.nextPageToken,
          ),
        ],
      );

      blocTest<HotelsBloc, HotelsState>(
        'should trigger fetch when query is not empty',
        build: createBloc,
        setUp: () {
          when(() => mockFetchHotelsUseCase.call(
                params: any(named: 'params'),
                pageToken: any(named: 'pageToken'),
              )).thenAnswer((_) async => firstPageResponse);
        },
        act: (bloc) {
          bloc.add(HotelsSearchUpdateEvent(params: defaultSearchParams));
        },
        wait: const Duration(milliseconds: 600), // Wait for debounce
        expect: () => [
          HotelsState(params: defaultSearchParams),
          HotelsState(
            params: defaultSearchParams,
            loading: true,
          ),
          HotelsState(
            params: defaultSearchParams,
            items: firstPageResponse.items,
            nextPageToken: firstPageResponse.nextPageToken,
          ),
        ],
      );

      blocTest<HotelsBloc, HotelsState>(
        'should not trigger fetch when query is empty',
        build: createBloc,
        act: (bloc) {
          bloc.add(HotelsSearchUpdateEvent(params: emptyQuerySearchParams));
        },
        wait: const Duration(milliseconds: 600),
        expect: () => [
          HotelsState(params: emptyQuerySearchParams),
        ],
        verify: (_) {
          verifyNever(() => mockFetchHotelsUseCase.call(
                params: any(named: 'params'),
                pageToken: any(named: 'pageToken'),
              ));
        },
      );

      blocTest<HotelsBloc, HotelsState>(
        'should debounce multiple rapid search updates',
        build: createBloc,
        setUp: () {
          when(() => mockFetchHotelsUseCase.call(
                params: any(named: 'params'),
                pageToken: any(named: 'pageToken'),
              )).thenAnswer((_) async => firstPageResponse);
        },
        act: (bloc) {
          // Rapid fire search updates
          bloc.add(HotelsSearchUpdateEvent(
            params: createSearchParams(query: 'N'),
          ));
          bloc.add(HotelsSearchUpdateEvent(
            params: createSearchParams(query: 'Ne'),
          ));
          bloc.add(HotelsSearchUpdateEvent(
            params: createSearchParams(query: 'New'),
          ));
          bloc.add(HotelsSearchUpdateEvent(
            params: createSearchParams(query: 'New York'),
          ));
        },
        wait: const Duration(milliseconds: 600),
        verify: (_) {
          // Should only call the API once due to debouncing
          verify(() => mockFetchHotelsUseCase.call(
                params: any(named: 'params'),
                pageToken: any(named: 'pageToken'),
              )).called(1);
        },
      );
    });

    group('HotelsFetchNextPageEvent', () {
      blocTest<HotelsBloc, HotelsState>(
        'should fetch first page successfully',
        build: createBloc,
        setUp: () {
          when(() => mockFetchHotelsUseCase.call(
                params: any(named: 'params'),
                pageToken: any(named: 'pageToken'),
              )).thenAnswer((_) async => firstPageResponse);
        },
        seed: () => HotelsState(params: defaultSearchParams),
        act: (bloc) {
          bloc.add(const HotelsFetchNextPageEvent());
        },
        expect: () => [
          HotelsState(
            params: defaultSearchParams,
            loading: true,
          ),
          HotelsState(
            params: defaultSearchParams,
            items: firstPageResponse.items,
            nextPageToken: firstPageResponse.nextPageToken,
          ),
        ],
      );

      blocTest<HotelsBloc, HotelsState>(
        'should append items when fetching next page',
        build: createBloc,
        setUp: () {
          when(() => mockFetchHotelsUseCase.call(
                params: any(named: 'params'),
                pageToken: 'page_2_token',
              )).thenAnswer((_) async => lastPageResponse);
        },
        seed: () => HotelsState(
          params: defaultSearchParams,
          items: firstPageResponse.items,
          nextPageToken: firstPageResponse.nextPageToken,
        ),
        act: (bloc) {
          bloc.add(const HotelsFetchNextPageEvent());
        },
        expect: () => [
          HotelsState(
            params: defaultSearchParams,
            items: firstPageResponse.items,
            nextPageToken: firstPageResponse.nextPageToken,
            loading: true,
          ),
          HotelsState(
            params: defaultSearchParams,
            items: [
              ...firstPageResponse.items,
              ...lastPageResponse.items,
            ],
            nextPageToken: null,
            hasReachedMax: true,
          ),
        ],
      );

      blocTest<HotelsBloc, HotelsState>(
        'should handle fetch failure',
        build: createBloc,
        setUp: () {
          when(() => mockFetchHotelsUseCase.call(
                params: any(named: 'params'),
                pageToken: any(named: 'pageToken'),
              )).thenThrow(Exception('Network error'));
        },
        seed: () => HotelsState(params: defaultSearchParams),
        act: (bloc) {
          bloc.add(const HotelsFetchNextPageEvent());
        },
        expect: () => [
          HotelsState(
            params: defaultSearchParams,
            loading: true,
          ),
          predicate<HotelsState>((state) =>
              state.params == defaultSearchParams &&
              state.loading == false &&
              state.error is Exception &&
              state.items.isEmpty),
        ],
      );

      blocTest<HotelsBloc, HotelsState>(
        'should clear previous error when fetching',
        build: createBloc,
        setUp: () {
          when(() => mockFetchHotelsUseCase.call(
                params: any(named: 'params'),
                pageToken: any(named: 'pageToken'),
              )).thenAnswer((_) async => firstPageResponse);
        },
        seed: () => HotelsState(
          params: defaultSearchParams,
          error: Exception('Previous error'),
        ),
        act: (bloc) {
          bloc.add(const HotelsFetchNextPageEvent());
        },
        expect: () => [
          HotelsState(
            params: defaultSearchParams,
            loading: true,
          ),
          HotelsState(
            params: defaultSearchParams,
            items: firstPageResponse.items,
            nextPageToken: firstPageResponse.nextPageToken,
          ),
        ],
      );

      blocTest<HotelsBloc, HotelsState>(
        'should handle empty response',
        build: createBloc,
        setUp: () {
          when(() => mockFetchHotelsUseCase.call(
                params: any(named: 'params'),
                pageToken: any(named: 'pageToken'),
              )).thenAnswer((_) async => emptyResponse);
        },
        seed: () => HotelsState(params: defaultSearchParams),
        act: (bloc) {
          bloc.add(const HotelsFetchNextPageEvent());
        },
        expect: () => [
          HotelsState(
            params: defaultSearchParams,
            loading: true,
          ),
          HotelsState(
            params: defaultSearchParams,
            items: const [],
            nextPageToken: null,
            hasReachedMax: true,
          ),
        ],
      );
    });

    group('HotelsFetchSuccessEvent', () {
      blocTest<HotelsBloc, HotelsState>(
        'should update state with fetched data',
        build: createBloc,
        seed: () => HotelsState(
          params: defaultSearchParams,
          loading: true,
        ),
        act: (bloc) {
          bloc.add(HotelsFetchSuccessEvent(response: firstPageResponse));
        },
        expect: () => [
          HotelsState(
            params: defaultSearchParams,
            items: firstPageResponse.items,
            nextPageToken: firstPageResponse.nextPageToken,
          ),
        ],
      );

      blocTest<HotelsBloc, HotelsState>(
        'should append to existing items',
        build: createBloc,
        seed: () => HotelsState(
          params: defaultSearchParams,
          items: [defaultHotel],
          loading: true,
        ),
        act: (bloc) {
          bloc.add(HotelsFetchSuccessEvent(response: firstPageResponse));
        },
        expect: () => [
          HotelsState(
            params: defaultSearchParams,
            items: [
              defaultHotel,
              ...firstPageResponse.items,
            ],
            nextPageToken: firstPageResponse.nextPageToken,
          ),
        ],
      );

      blocTest<HotelsBloc, HotelsState>(
        'should set hasReachedMax when nextPageToken is null',
        build: createBloc,
        seed: () => HotelsState(
          params: defaultSearchParams,
          loading: true,
        ),
        act: (bloc) {
          bloc.add(HotelsFetchSuccessEvent(response: lastPageResponse));
        },
        expect: () => [
          HotelsState(
            params: defaultSearchParams,
            items: lastPageResponse.items,
            nextPageToken: null,
            hasReachedMax: true,
          ),
        ],
      );
    });

    group('HotelsFetchFailureEvent', () {
      blocTest<HotelsBloc, HotelsState>(
        'should update state with error',
        build: createBloc,
        seed: () => HotelsState(
          params: defaultSearchParams,
          loading: true,
        ),
        act: (bloc) {
          final error = Exception('Test error');
          bloc.add(HotelsFetchFailureEvent(error: error));
        },
        expect: () => [
          predicate<HotelsState>((state) =>
              state.params == defaultSearchParams &&
              state.loading == false &&
              state.error is Exception &&
              state.items.isEmpty),
        ],
      );

      blocTest<HotelsBloc, HotelsState>(
        'should preserve existing items when error occurs',
        build: createBloc,
        seed: () => HotelsState(
          params: defaultSearchParams,
          items: [defaultHotel],
          loading: true,
        ),
        act: (bloc) {
          final error = Exception('Test error');
          bloc.add(HotelsFetchFailureEvent(error: error));
        },
        expect: () => [
          predicate<HotelsState>((state) =>
              state.params == defaultSearchParams &&
              state.loading == false &&
              state.error is Exception &&
              state.items.length == 1 &&
              state.items.first == defaultHotel),
        ],
      );
    });

    group('state properties', () {
      test('hasError should return true when error is not null', () {
        // Arrange
        final state = HotelsState(
          params: defaultSearchParams,
          error: Exception('Test error'),
        );

        // Act & Assert
        expect(state.hasError, isTrue);
      });

      test('hasError should return false when error is null', () {
        // Arrange
        final state = HotelsState(params: defaultSearchParams);

        // Act & Assert
        expect(state.hasError, isFalse);
      });

      test('copyWith should create new instance with updated values', () {
        // Arrange
        final originalState = HotelsState(
          params: defaultSearchParams,
          loading: false,
          items: [],
        );

        // Act
        final newState = originalState.copyWith(
          loading: true,
          items: [defaultHotel],
        );

        // Assert
        expect(newState.loading, isTrue);
        expect(newState.items, equals([defaultHotel]));
        expect(newState.params, equals(originalState.params));
        expect(originalState.loading, isFalse); // Original unchanged
      });

      test('copyWith should handle null nextPageToken setting', () {
        // Arrange
        final originalState = HotelsState(
          params: defaultSearchParams,
          nextPageToken: 'some_token',
        );

        // Act
        final newState = originalState.copyWith(
          nextPageToken: null,
          setNextPageToken: true,
        );

        // Assert
        expect(newState.nextPageToken, isNull);
      });

      test('copyWith should handle error setting', () {
        // Arrange
        final originalState = HotelsState(
          params: defaultSearchParams,
          error: Exception('Old error'),
        );

        // Act
        final newState = originalState.copyWith(
          error: null,
          setError: true,
        );

        // Assert
        expect(newState.error, isNull);
      });
    });

    group('integration scenarios', () {
      blocTest<HotelsBloc, HotelsState>(
        'should handle complete search and pagination flow',
        build: createBloc,
        setUp: () {
          when(() => mockFetchHotelsUseCase.call(
                params: any(named: 'params'),
                pageToken: null,
              )).thenAnswer((_) async => firstPageResponse);

          when(() => mockFetchHotelsUseCase.call(
                params: any(named: 'params'),
                pageToken: 'page_2_token',
              )).thenAnswer((_) async => lastPageResponse);
        },
        act: (bloc) async {
          // Start search
          bloc.add(HotelsSearchUpdateEvent(params: defaultSearchParams));

          // Wait for debounce and first page
          await Future.delayed(const Duration(milliseconds: 600));

          // Fetch next page
          bloc.add(const HotelsFetchNextPageEvent());
        },
        wait: const Duration(milliseconds: 700),
        expect: () => [
          // Search update
          HotelsState(params: defaultSearchParams),
          // Loading first page
          HotelsState(
            params: defaultSearchParams,
            loading: true,
          ),
          // First page loaded
          HotelsState(
            params: defaultSearchParams,
            items: firstPageResponse.items,
            nextPageToken: 'page_2_token',
          ),
          // Loading next page
          HotelsState(
            params: defaultSearchParams,
            items: firstPageResponse.items,
            nextPageToken: 'page_2_token',
            loading: true,
          ),
          // Next page loaded
          HotelsState(
            params: defaultSearchParams,
            items: [
              ...firstPageResponse.items,
              ...lastPageResponse.items,
            ],
            nextPageToken: null,
            hasReachedMax: true,
          ),
        ],
      );

      blocTest<HotelsBloc, HotelsState>(
        'should handle error recovery',
        build: createBloc,
        setUp: () {
          var callCount = 0;
          when(() => mockFetchHotelsUseCase.call(
                params: any(named: 'params'),
                pageToken: any(named: 'pageToken'),
              )).thenAnswer((_) async {
            callCount++;
            if (callCount == 1) {
              throw Exception('Network error');
            }
            return firstPageResponse;
          });
        },
        seed: () => HotelsState(params: defaultSearchParams),
        act: (bloc) {
          // First attempt - will fail
          bloc.add(const HotelsFetchNextPageEvent());
          // Retry - will succeed
          bloc.add(const HotelsFetchNextPageEvent());
        },
        expect: () => [
          // First attempt loading
          HotelsState(
            params: defaultSearchParams,
            loading: true,
          ),
          // First attempt error
          predicate<HotelsState>((state) =>
              state.params == defaultSearchParams &&
              state.loading == false &&
              state.error is Exception &&
              state.items.isEmpty),
          // Retry success (no loading state due to droppable transformer)
          HotelsState(
            params: defaultSearchParams,
            items: firstPageResponse.items,
            nextPageToken: firstPageResponse.nextPageToken,
          ),
        ],
      );
    });
  });
}