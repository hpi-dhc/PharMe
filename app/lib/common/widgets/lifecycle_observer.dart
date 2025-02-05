import '../module.dart';

class LifecycleObserver extends HookWidget {
  const LifecycleObserver({
    super.key,
    required this.appRouter,
    required this.child,
  });

  final AppRouter appRouter;
  final Widget child;
  
  @override
  Widget build(BuildContext context) {  
    useOnAppLifecycleStateChange((previous, current) async {
      if (current == AppLifecycleState.resumed) {
        await routeBackAfterSecurePage(appRouter);
      }
      if (
        current == AppLifecycleState.inactive ||
        current == AppLifecycleState.paused
      ) {
        if (!currentPathIsSecurePath(appRouter)) {
          await appRouter.push(SecureRoute());
        }
      }
    });
    return child;
  }
}