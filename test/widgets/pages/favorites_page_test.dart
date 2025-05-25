import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hotel_booking/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:hotel_booking/features/favorites/presentation/pages/favorites_page.dart';

import '../../helpers/test_data_factory.dart';
import '../../helpers/widget_test_helpers.dart';
import '../../helpers/bloc_test_helpers.dart';

void main() {
  group('FavoritesPage Widget', () {
    late MockFavoritesBloc mockFavoritesBloc;

    setUpAll(() {
      registerFallbackValue(RemoveFavoriteEvent(hotel: TestDataFactory.defaultHotel));
    });

    setUp(() {
      mockFavoritesBloc = BlocTestHelpers.createMockFavoritesBloc();
      when(() => mockFavoritesBloc.close()).thenAnswer((_) async {});
    });

    tearDown(() {
      mockFavoritesBloc.close();
    });

    Widget createFavoritesPage() {
      return WidgetTestHelpers.createTestApp(
        child: const FavoritesPage(),
        favoritesBloc: mockFavoritesBloc,
      );
    }

    testWidgets('should display app bar with title', (tester) async {
      // Arrange
      when(() => mockFavoritesBloc.state).thenReturn(
        BlocTestHelpers.createEmptyFavoritesState(),
      );

      // Act
      await tester.pumpWidget(createFavoritesPage());

      // Assert
      expect(find.byKey(const Key('favorites_app_bar')), findsOneWidget);
      expect(find.byKey(const Key('favorites_title')), findsOneWidget);
      expect(find.text('Your Favorite Hotels'), findsOneWidget);
    });

    testWidgets('should display empty state when no favorites', (tester) async {
      // Arrange
      when(() => mockFavoritesBloc.state).thenReturn(
        BlocTestHelpers.createEmptyFavoritesState(),
      );

      // Act
      await tester.pumpWidget(createFavoritesPage());

      // Assert
      expect(find.byKey(const Key('favorites_empty_state_icon')), findsOneWidget);
      expect(find.byIcon(Icons.favorite_outline), findsOneWidget);
    });

    testWidgets('should display favorites list when data is available', (tester) async {
      // Arrange
      when(() => mockFavoritesBloc.state).thenReturn(
        BlocTestHelpers.createFavoritesStateWithHotels(TestDataFactory.multipleHotels),
      );

      // Act
      await tester.pumpWidget(createFavoritesPage());

      // Assert
      expect(find.byKey(const Key('favorites_list_view')), findsOneWidget);
      expect(find.text(TestDataFactory.defaultHotel.name), findsOneWidget);
    });

    testWidgets('should trigger remove favorite when favorite button is tapped', (tester) async {
      // Arrange
      when(() => mockFavoritesBloc.state).thenReturn(
        BlocTestHelpers.createFavoritesStateWithHotels([TestDataFactory.defaultHotel]),
      );

      await tester.pumpWidget(createFavoritesPage());

      // Act
      final favoriteButton = find.byType(IconButton).first;
      await tester.tap(favoriteButton);
      await tester.pump();

      // Assert
      verify(() => mockFavoritesBloc.add(any(that: isA<RemoveFavoriteEvent>()))).called(1);
    });
  });
}