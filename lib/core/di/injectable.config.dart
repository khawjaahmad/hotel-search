// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:hotel_booking/core/network/api_client.dart' as _i235;
import 'package:hotel_booking/core/network/api_client_impl.dart' as _i779;
import 'package:hotel_booking/core/network/network.dart' as _i757;
import 'package:hotel_booking/features/favorites/data/data_sources/data_sources.dart'
    as _i490;
import 'package:hotel_booking/features/favorites/data/data_sources/favorites_local_data_source_hive_impl.dart'
    as _i295;
import 'package:hotel_booking/features/favorites/data/repositories/favorites_repository_impl.dart'
    as _i887;
import 'package:hotel_booking/features/favorites/domain/repositories/repositores.dart'
    as _i10;
import 'package:hotel_booking/features/favorites/domain/usecases/add_favorite_usecase.dart'
    as _i810;
import 'package:hotel_booking/features/favorites/domain/usecases/check_favorite_usecase.dart'
    as _i847;
import 'package:hotel_booking/features/favorites/domain/usecases/get_favorites_usecase.dart'
    as _i992;
import 'package:hotel_booking/features/favorites/domain/usecases/remove_favorite_usecase.dart'
    as _i956;
import 'package:hotel_booking/features/favorites/domain/usecases/watch_favorites_usecase.dart'
    as _i956;
import 'package:hotel_booking/features/hotels/data/data_sources/data_sources.dart'
    as _i239;
import 'package:hotel_booking/features/hotels/data/data_sources/hotels_remote_data_source.dart'
    as _i666;
import 'package:hotel_booking/features/hotels/data/data_sources/hotels_remote_data_source_serpapi_impl.dart'
    as _i401;
import 'package:hotel_booking/features/hotels/data/repositories/hotels_repository_impl.dart'
    as _i83;
import 'package:hotel_booking/features/hotels/domain/repositories/repositories.dart'
    as _i874;
import 'package:hotel_booking/features/hotels/domain/usecases/fetch_hotels_usecase.dart'
    as _i568;
import 'package:http/http.dart' as _i519;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final httpClientModule = _$HttpClientModule();
    gh.lazySingleton<_i519.Client>(() => httpClientModule.client);
    gh.singleton<_i490.FavoritesLocalDataSource>(
        () => _i295.FavoritesLocalDataSourceHiveImpl());
    gh.singleton<_i235.ApiClient>(
        () => _i779.ApiClientImpl(client: gh<_i519.Client>()));
    gh.singleton<_i666.HotelsRemoteDataSource>(() =>
        _i401.HotelsRemoteDataSourceSerpapiImpl(
            apiClient: gh<_i757.ApiClient>()));
    gh.singleton<_i10.FavoritesRepository>(() => _i887.FavoritesRepositoryImpl(
        favoritesLocalDataSource: gh<_i490.FavoritesLocalDataSource>()));
    gh.lazySingleton<_i956.RemoveFavoriteUseCase>(() =>
        _i956.RemoveFavoriteUseCase(
            favoritesRepository: gh<_i10.FavoritesRepository>()));
    gh.lazySingleton<_i810.AddFavoriteUseCase>(() => _i810.AddFavoriteUseCase(
        favoritesRepository: gh<_i10.FavoritesRepository>()));
    gh.lazySingleton<_i956.WatchFavoritesUseCase>(() =>
        _i956.WatchFavoritesUseCase(
            favoritesRepository: gh<_i10.FavoritesRepository>()));
    gh.lazySingleton<_i847.CheckFavoriteUseCase>(() =>
        _i847.CheckFavoriteUseCase(
            favoritesRepository: gh<_i10.FavoritesRepository>()));
    gh.lazySingleton<_i992.GetFavoritesUseCase>(() => _i992.GetFavoritesUseCase(
        favoritesRepository: gh<_i10.FavoritesRepository>()));
    gh.singleton<_i874.HotelsRepository>(() => _i83.HotelsRepositoryImpl(
        hotelsRemoteDataSource: gh<_i239.HotelsRemoteDataSource>()));
    gh.lazySingleton<_i568.FetchHotelsUseCase>(() => _i568.FetchHotelsUseCase(
        hotelsRepository: gh<_i874.HotelsRepository>()));
    return this;
  }
}

class _$HttpClientModule extends _i779.HttpClientModule {}
