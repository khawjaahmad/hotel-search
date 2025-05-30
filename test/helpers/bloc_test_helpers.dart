import 'package:bloc_test/bloc_test.dart';
import 'package:hotel_booking/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:hotel_booking/features/hotels/domain/entities/entities.dart';
import 'package:hotel_booking/features/hotels/presentation/bloc/hotels_bloc.dart';

class BlocTestHelpers {
  static MockFavoritesBloc createMockFavoritesBloc() {
    return MockFavoritesBloc();
  }

  static MockHotelsBloc createMockHotelsBloc() {
    return MockHotelsBloc();
  }

  static FavoritesState createEmptyFavoritesState() {
    return FavoritesState(items: []);
  }

  static FavoritesState createFavoritesStateWithHotels(List<Hotel> hotels) {
    return FavoritesState(items: hotels);
  }

  static HotelsState createInitialHotelsState() {
    return HotelsState(
      params: SearchParams(
        query: '',
        checkInDate: DateTime.now(),
        checkOutDate: DateTime.now().add(const Duration(days: 1)),
      ),
    );
  }

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

class MockFavoritesBloc extends MockBloc<FavoritesEvent, FavoritesState>
    implements FavoritesBloc {}

class MockHotelsBloc extends MockBloc<HotelsEvent, HotelsState>
    implements HotelsBloc {}
