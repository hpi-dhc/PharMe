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

bool currentPathIsSecurePath(StackRouter router) {
  return router.currentPath == secureRoutePath;
}

Future<void> routeBackAfterSecurePage(StackRouter router) async {
  if (currentPathIsSecurePath(router)) {
    if (router.canPop()) {
      await router.maybePop();
    } else {
      await router.pushNamed(getInitialRouteName());
    }
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