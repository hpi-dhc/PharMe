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

  Future<void> _handleError({
    required Object exception,
    StackTrace? stackTrace,
  }) async {
    debugPrint(exception.toString());
    debugPrintStack(stackTrace: stackTrace);
    final errorString = exception.toString();
    if (_needToHandleError(exception)) {
      final errorMailInfo = stackTrace != null
        ? '$errorString\n\n${stackTrace.toString()}'
        : errorString;
      await widget.appRouter.push(ErrorRoute(error: errorMailInfo));
    }
  }

  bool _needToHandleError(Object exception) {
    final willIgnoreError = exception is FlutterError &&
      exception.message.startsWith('A RenderFlex overflowed');
    return !willIgnoreError;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}