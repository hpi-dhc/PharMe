import '../module.dart';

class ErrorHandler extends StatefulWidget {
  const ErrorHandler({
    super.key,
    required this.appRouter,
    required this.child,
  });

  final AppRouter appRouter;
  final Widget child;

  @override
  State<StatefulWidget> createState() => ErrorHandlerState();
}

class ErrorHandlerState extends State<ErrorHandler> {
  Future<void> _handleError({
    required Object exception,
    StackTrace? stackTrace,
  }) async {
    debugPrint(exception.toString());
    debugPrintStack(stackTrace: stackTrace);
    await widget.appRouter.push(ErrorRoute(error: exception.toString()));
  }

  @override
  void initState() {
    FlutterError.onError = (details) {
      _handleError(exception: details.exception, stackTrace: details.stack);
    };
    WidgetsBinding.instance.platformDispatcher.onError =
      (exception, stackTrace) {
        _handleError(exception: exception, stackTrace: stackTrace);
        return true;
      };
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}