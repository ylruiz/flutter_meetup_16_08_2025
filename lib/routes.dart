import 'package:auto_route/auto_route.dart';
import 'package:flutter_meetup_16_08_2025/paths.dart';
import 'package:flutter_meetup_16_08_2025/routes.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => RouteType.material(); //.cupertino, .adaptive ..etc

  @override
  List<AutoRoute> get routes => [
    AutoRoute(path: Paths.onboarding, page: OnboardingRoute.page),
    // HomeScreen is generated as HomeRoute because
    // of the replaceInRouteName property
    AutoRoute(path: Paths.home, page: HomeRoute.page),
  ];

  @override
  List<AutoRouteGuard> get guards => [
    // optionally add root guards here
  ];
}
