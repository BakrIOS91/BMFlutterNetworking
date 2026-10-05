import 'package:auto_route/auto_route.dart';
import 'package:flutter_example/core/router/app_router.gr.dart';
import 'package:injectable/injectable.dart';

@singleton
@AutoRouterConfig(replaceInRouteName: 'View|Page,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType =>
      RouteType.material(); //.cupertino, .adaptive ..etc

  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: SplashRoute.page, initial: true),
        AutoRoute(page: OnboardingRoute.page),
        AutoRoute(page: LoginRoute.page),
        AutoRoute(page: TabRoute.page),
        AutoRoute(page: RegisterRoute.page),
        AutoRoute(page: AccountInfoRoute.page),
        AutoRoute(page: PopularItemsRoute.page),
        AutoRoute(page: SearchRoute.page),
        AutoRoute(page: HotelBookingRoute.page),

        AutoRoute(page: HotelDetailsRoute.page),
        AutoRoute(page: FacilitiesListRoute.page),
        AutoRoute(page: CheckoutRoute.page),
      ];

  @override
  List<AutoRouteGuard> get guards => [
        // optionally add root guards here
      ];
}
