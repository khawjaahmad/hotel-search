// test/widget/pages/hotels_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hotel_booking/features/hotels/presentation/bloc/hotels_bloc.dart';
import 'package:hotel_booking/features/hotels/presentation/pages/hotels_page.dart';

import '../../helpers/test_data_factory.dart';
import '../../helpers/widget_test_helpers.dart';
import '../../helpers/bloc_test_helpers.dart';

void main() {
  group('HotelsPage Widget', () {
    late MockHotelsBloc mockHotelsBloc;
    late MockFavoritesBloc mockFavoritesBloc;

    setUpAll(() {
      registerFallbackValue(const HotelsFetchNextPageEvent());
    });

    setUp(() {
      mockHotelsBloc = BlocTestHelpers.createMockHotelsBloc();
      mockFavoritesBloc = BlocTestHelpers.createMockFavoritesBloc();
      
      when(() => mockHotelsBloc.close()).thenAnswer((_) async {});
      when(() => mockFavoritesBloc.close()).thenAnswer((_) async {});
    });

    tearDown(() {
      mockHotelsBloc.close();
      mockFavoritesBloc.close();
    });

    Widget createHotelsPage() {
      return WidgetTestHelpers.createTestApp(
        child: const HotelsPage(),
        hotelsBloc: mockHotelsBloc,
        favoritesBloc: mockFavoritesBloc,
      );
    }

    testWidgets('should display search field in app bar', (tester) async {
      // Arrange
      when(() => mockHotelsBloc.state).thenReturn(
        BlocTestHelpers.createInitialHotelsState(),
      );
      when(() => mockFavoritesBloc.state).thenReturn(
        BlocTestHelpers.createEmptyFavoritesState(),
      );

      // Act
      await tester.pumpWidget(createHotelsPage());

      // Assert
      expect(find.byKey(const Key('hotels_search_field')), findsOneWidget);
      expect(find.byKey(const Key('hotels_app_bar')), findsOneWidget);
    });

    testWidgets('should display loading indicator when loading with empty items', (tester) async {
      // Arrange
      when(() => mockHotelsBloc.state).thenReturn(
        BlocTestHelpers.createLoadingHotelsState(),
      );
      when(() => mockFavoritesBloc.state).thenReturn(
        BlocTestHelpers.createEmptyFavoritesState(),
      );

      // Act
      await tester.pumpWidget(createHotelsPage());

      // Assert
      expect(find.byKey(const Key('hotels_loading_indicator')), findsOneWidget);
    });

    testWidgets('should display error message when error occurs', (tester) async {
      // Arrange
      when(() => mockHotelsBloc.state).thenReturn(
        BlocTestHelpers.createErrorHotelsState(Exception('Network error')),
      );
      when(() => mockFavoritesBloc.state).thenReturn(
        BlocTestHelpers.createEmptyFavoritesState(),
      );

      // Act
      await tester.pumpWidget(createHotelsPage());

      // Assert
      expect(find.byKey(const Key('hotels_error_message')), findsOneWidget);
      expect(find.byKey(const Key('hotels_retry_button')), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('should display empty state icon when no items and not loading', (tester) async {
      // Arrange
      when(() => mockHotelsBloc.state).thenReturn(
        BlocTestHelpers.createInitialHotelsState(),
      );
      when(() => mockFavoritesBloc.state).thenReturn(
        BlocTestHelpers.createEmptyFavoritesState(),
      );

      // Act
      await tester.pumpWidget(createHotelsPage());

      // Assert
      expect(find.byKey(const Key('hotels_empty_state_icon')), findsOneWidget);
      expect(find.byIcon(Icons.hotel_outlined), findsOneWidget);
    });

    testWidgets('should display hotels list when data is available', (tester) async {
      // Arrange
      when(() => mockHotelsBloc.state).thenReturn(
        BlocTestHelpers.createHotelsStateWithData(TestDataFactory.multipleHotels),
      );
      when(() => mockFavoritesBloc.state).thenReturn(
        BlocTestHelpers.createEmptyFavoritesState(),
      );

      // Act
      await tester.pumpWidget(createHotelsPage());

      // Assert
      expect(find.byKey(const Key('hotels_scroll_view')), findsOneWidget);
      expect(find.byKey(const Key('hotels_list')), findsOneWidget);
    });

    testWidgets('should trigger retry when retry button is tapped', (tester) async {
      // Arrange
      when(() => mockHotelsBloc.state).thenReturn(
        BlocTestHelpers.createErrorHotelsState(Exception('Network error')),
      );
      when(() => mockFavoritesBloc.state).thenReturn(
        BlocTestHelpers.createEmptyFavoritesState(),
      );

      await tester.pumpWidget(createHotelsPage());

      // Act
      await tester.tap(find.byKey(const Key('hotels_retry_button')));
      await tester.pump();

      // Assert
      verify(() => mockHotelsBloc.add(any(that: isA<HotelsFetchNextPageEvent>()))).called(1);
    });
  });
}

