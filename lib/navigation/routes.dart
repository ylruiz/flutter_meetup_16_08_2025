import 'package:auto_route/auto_route.dart';
import 'package:flutter_meetup_16_08_2025/navigation/paths.dart';
import 'package:flutter_meetup_16_08_2025/navigation/routes.gr.dart';

import 'onboarding_guard.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  final OnboardingGuard onboardingGuard = OnboardingGuard();

  @override
  RouteType get defaultRouteType => RouteType.material();

  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      path: Paths.onboarding,
      page: OnboardingRoute.page,
      guards: [onboardingGuard],
    ),
    AutoRoute(path: Paths.home, page: HomeRoute.page),
  ];
}
