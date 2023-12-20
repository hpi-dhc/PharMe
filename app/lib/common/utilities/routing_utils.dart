import '../module.dart';

DeepLink getInitialRoute(_) {
  final isLoggedIn = MetaData.instance.isLoggedIn ?? false;
  final onboardingDone = MetaData.instance.onboardingDone ?? false;
  final initialDrugSelectionDone =
    MetaData.instance.initialDrugSelectionDone ?? false;
  late String path;
    path = !isLoggedIn
      ? '/login'
      : !onboardingDone
        ? '/onboarding'
        : !initialDrugSelectionDone
          ? '/drugselection'
          : '/main';
  return DeepLink.path(path);
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