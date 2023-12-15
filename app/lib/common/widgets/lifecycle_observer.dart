import '../module.dart';

class LifecycleObserver extends HookWidget {
  const LifecycleObserver({
    Key? key,
    required this.appRouter,
    required this.child,
  }) : super(key: key);

  final AppRouter appRouter;
  final Widget child;
  
  @override
  Widget build(BuildContext context) {  
    useOnAppLifecycleStateChange((previous, current) async {
      if (current == AppLifecycleState.resumed) {
        appRouter.navigateBack();
      }
      if (
        current == AppLifecycleState.inactive ||
        current == AppLifecycleState.paused
      ) {
        await appRouter.push(PrivacyRouter());
      }
    });
    return child;
  }
}