import 'package:auto_route/auto_route.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'paths.dart';

class OnboardingGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    final prefs = await SharedPreferences.getInstance();
    final isOnboardingCompleted =
        prefs.getBool('isOnboardingCompleted') ?? false;

    if (isOnboardingCompleted) {
      // Skip onboarding and go to home
      router.replacePath(Paths.home);
    } else {
      resolver.next(true); // Allow onboarding route
    }
  }
}
