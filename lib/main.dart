import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'package:hotel_booking/core/di/injectable.dart';
import 'package:hotel_booking/core/navigation/navigation.dart';
import 'package:hotel_booking/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:hotel_booking/features/hotels/presentation/bloc/hotels_bloc.dart';
import 'package:hotel_booking/i18n/strings.g.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      statusBarColor: Colors.transparent,
    ),
  );
  EquatableConfig.stringify = true;
  Bloc.observer = SimpleBlocObserver();
  Hive.defaultDirectory = (await getApplicationDocumentsDirectory()).path;
  LocaleSettings.useDeviceLocale();
  configureDependencies();
  runApp(App());
}

class App extends StatelessWidget {
  App({super.key});

  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => HotelsBloc(
            fetchHotelsUseCase: getIt(),
          ),
        ),
        BlocProvider(
          create: (_) => FavoritesBloc(
            getFavoritesUseCase: getIt(),
            watchFavoritesUseCase: getIt(),
            addFavoriteUseCase: getIt(),
            removeFavoriteUseCase: getIt(),
          ),
        ),
      ],
      child: MaterialApp.router(
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        routerConfig: _appRouter.config(),
      ),
    );
  }
}

class SimpleBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    // ignore: avoid_print
    print('${bloc.runtimeType} $change');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    // ignore: avoid_print
    print('${bloc.runtimeType} $transition');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    // ignore: avoid_print
    print('${bloc.runtimeType} $error $stackTrace');
    super.onError(bloc, error, stackTrace);
  }
}
