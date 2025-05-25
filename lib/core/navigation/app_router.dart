import 'package:auto_route/auto_route.dart';

import 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes {
    return [
      AutoRoute(
        path: '/dashboard',
        page: DashboardRoute.page,
        initial: true,
        children: [
          AutoRoute(path: 'overview', page: OverviewRoute.page),
          AutoRoute(path: 'hotels', page: HotelsRoute.page),
          AutoRoute(path: 'favorites', page: FavoritesRoute.page),
          AutoRoute(path: 'account', page: AccountRoute.page),
        ],
      ),
    ];
  }
}
