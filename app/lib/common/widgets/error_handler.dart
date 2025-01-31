import 'package:flutter/foundation.dart';

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

  bool _isNonFatalTestError(Object exception) {
    return exception.toString().contains(nonFatalTestErrorMessage);
  }

  bool _needToHandleError(Object exception) {
    final ignoreTestError = kDebugMode && _isNonFatalTestError(exception);
    final isOverflowError = exception is FlutterError &&
      exception.message.startsWith('A RenderFlex overflowed');
    final willIgnoreError = isOverflowError || ignoreTestError;
    return !willIgnoreError;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}