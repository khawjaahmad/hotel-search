import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_booking/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:hotel_booking/features/hotels/presentation/bloc/hotels_bloc.dart';

class WidgetTestHelpers {
  static Widget createTestApp({
    required Widget child,
    FavoritesBloc? favoritesBloc,
    HotelsBloc? hotelsBloc,
  }) {
    return MultiBlocProvider(
      providers: [
        if (favoritesBloc != null)
          BlocProvider<FavoritesBloc>.value(value: favoritesBloc),
        if (hotelsBloc != null)
          BlocProvider<HotelsBloc>.value(value: hotelsBloc),
      ],
      child: MaterialApp(
        home: child,
        theme: ThemeData.light(),
      ),
    );
  }

  static Widget createTestAppWithRouter({
    required Widget child,
    FavoritesBloc? favoritesBloc,
    HotelsBloc? hotelsBloc,
  }) {
    return MultiBlocProvider(
      providers: [
        if (favoritesBloc != null)
          BlocProvider<FavoritesBloc>.value(value: favoritesBloc),
        if (hotelsBloc != null)
          BlocProvider<HotelsBloc>.value(value: hotelsBloc),
      ],
      child: MaterialApp(
        home: Scaffold(body: child),
        theme: ThemeData.light(),
      ),
    );
  }

  static Widget createTestAppWithTheme({
    required Widget child,
    required ThemeData theme,
    FavoritesBloc? favoritesBloc,
    HotelsBloc? hotelsBloc,
  }) {
    return MultiBlocProvider(
      providers: [
        if (favoritesBloc != null)
          BlocProvider<FavoritesBloc>.value(value: favoritesBloc),
        if (hotelsBloc != null)
          BlocProvider<HotelsBloc>.value(value: hotelsBloc),
      ],
      child: MaterialApp(
        home: child,
        theme: theme,
      ),
    );
  }

  static Widget createScaffoldWrapper(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }
}
