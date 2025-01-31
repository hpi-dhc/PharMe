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
  @override
  void initState() {
    FlutterError.onError = (details) async {
      await _handleError(exception: details.exception, stackTrace: details.stack);
    };
    WidgetsBinding.instance.platformDispatcher.onError =
      (exception, stackTrace) {
        _handleError(exception: exception, stackTrace: stackTrace);
        return true;
      };
    super.initState();
  }

  Future<void> _handleError({
    required Object exception,
    StackTrace? stackTrace,
  }) async {
    final isFatal = _needToHandleError(exception);
    final errorString = exception.toString();
    if (isFatal) {
      await widget.appRouter.push(ErrorRoute(error: errorString));
    }
  }

  bool _needToHandleError(Object exception) {
    // Set to false to test that error screen appears (annoying when debugging
    // with breakpoints anyways)
    const ignoreTestError = true;
    final isTestError = exception.toString().contains(testErrorMessage);
    final isOverflowError = exception is FlutterError &&
      exception.message.startsWith('A RenderFlex overflowed');
    final willIgnoreError = isOverflowError || (isTestError && ignoreTestError);
    return !willIgnoreError;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}