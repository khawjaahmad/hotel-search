import 'package:bloc_test/bloc_test.dart';
import 'package:hotel_booking/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:hotel_booking/features/hotels/presentation/bloc/hotels_bloc.dart';
import 'package:hotel_booking/features/hotels/domain/entities/entities.dart';

class BlocTestHelpers {
  /// Creates a mock FavoritesBloc for testing
  static MockFavoritesBloc createMockFavoritesBloc() {
    return MockFavoritesBloc();
  }

  /// Creates a mock HotelsBloc for testing
  static MockHotelsBloc createMockHotelsBloc() {
    return MockHotelsBloc();
  }

  /// Creates initial FavoritesState with empty items
  static FavoritesState createEmptyFavoritesState() {
    return FavoritesState(items: []);
  }

  /// Creates FavoritesState with test hotels
  static FavoritesState createFavoritesStateWithHotels(List<Hotel> hotels) {
    return FavoritesState(items: hotels);
  }

  /// Creates initial HotelsState for testing
  static HotelsState createInitialHotelsState() {
    return HotelsState(
      params: SearchParams(
        query: '',
        checkInDate: DateTime.now(),
        checkOutDate: DateTime.now().add(const Duration(days: 1)),
      ),
    );
  }

  /// Creates HotelsState with loading
  static HotelsState createLoadingHotelsState() {
    return HotelsState(
      loading: true,
      params: SearchParams(
        query: 'test',
        checkInDate: DateTime.now(),
        checkOutDate: DateTime.now().add(const Duration(days: 1)),
      ),
    );
  }

  /// Creates HotelsState with error
  static HotelsState createErrorHotelsState(dynamic error) {
    return HotelsState(
      params: SearchParams(
        query: 'test',
        checkInDate: DateTime.now(),
        checkOutDate: DateTime.now().add(const Duration(days: 1)),
      ),
      error: error,
    );
  }

  /// Creates HotelsState with data
  static HotelsState createHotelsStateWithData(List<Hotel> hotels) {
    return HotelsState(
      params: SearchParams(
        query: 'test',
        checkInDate: DateTime.now(),
        checkOutDate: DateTime.now().add(const Duration(days: 1)),
      ),
      items: hotels,
    );
  }
}

// Mock BLoCs for testing
class MockFavoritesBloc extends MockBloc<FavoritesEvent, FavoritesState>
    implements FavoritesBloc {}

class MockHotelsBloc extends MockBloc<HotelsEvent, HotelsState>
    implements HotelsBloc {}

