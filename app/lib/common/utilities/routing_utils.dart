import '../../secure/module.dart';
import '../module.dart';

String getInitialRouteName() {
  final isLoggedIn = MetaData.instance.isLoggedIn ?? false;
  final onboardingDone = MetaData.instance.onboardingDone ?? false;
  final initialDrugSelectionDone =
    MetaData.instance.initialDrugSelectionDone ?? false;
  return !isLoggedIn
      ? '/login'
      : !onboardingDone
        ? '/onboarding'
        : !initialDrugSelectionDone
          ? '/drugselection'
          : '/main';
}

DeepLink getInitialRoute() {
  return DeepLink.path(getInitialRouteName());
}

void routeBackToContent(
  StackRouter router,
  {
    bool popLogin = true,
    // Dialogs or modal bottom sheets will have no route name
    bool popNull = false,
  }) {
  final currentRoute = router.current.name;
  bool keepRoute(Route route) {
    final isSecureRoute = route.settings.name == SecureRoute.name;
    final isLoginRoute = route.settings.name == LoginRoute.name;
    final isCurrentRoute = route.settings.name == currentRoute;
    final isNullRoute = route.settings.name == null;
    var keepCurrentRoute = !isSecureRoute && !isCurrentRoute;
    if (popLogin) keepCurrentRoute = keepCurrentRoute && !isLoginRoute;
    if (popNull) keepCurrentRoute = keepCurrentRoute && !isNullRoute;
    return keepCurrentRoute;
  }
  router.popUntil(keepRoute);
}

bool currentPathIsSecurePath(StackRouter router) {
  return router.currentPath == secureRoutePath;
}

Future<void> routeBackAfterSecurePage(StackRouter router) async {
  if (currentPathIsSecurePath(router)) {
    routeBackToContent(router, popLogin: false);
  }
}

// Replace whole stack, see https://stackoverflow.com/a/73784156
Future<void> overwriteRoutes(
  BuildContext context,
  { required PageRouteInfo nextPage }
) async {
  await context.router.pushAndPopUntil(
    nextPage,
    predicate: (_) => false
  );
}