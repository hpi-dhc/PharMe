import 'package:app/app/routing/router.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AuthGuard extends AutoRouteGuard {
  @override
  Future<void> onNavigation(
      NavigationResolver resolver, StackRouter router) async {
    final isOnboardingCompleted = Hive.box('preferences')
        .get('isOnboardingCompleted', defaultValue: false) as bool;

    // ToDo: Check for isAuthenticated as well

    if (isOnboardingCompleted) {
      resolver.next(true);
    } else {
      final isLoginSuccessful =
          (await router.pushNamed('auth/onboarding') ?? false) as bool;
      resolver.next(isLoginSuccessful);
      print(isLoginSuccessful);
    }
  }
}
