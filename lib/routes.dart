import 'package:auto_route/auto_route.dart';

import 'on_boarding_guard.dart';
import 'paths.dart';
import 'routes.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  AppRouter({super.navigatorKey});

  final onboardingGuard = OnboardingGuard();

  @override
  RouteType get defaultRouteType => RouteType.material();

  @override
  List<AutoRoute> get routes => [
    AutoRoute(path: Paths.onboarding, page: OnboardingRoute.page),
    AutoRoute(
      path: Paths.home,
      page: HomeRoute.page,
      guards: [onboardingGuard],
    ),
  ];
}
