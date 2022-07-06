import 'module.dart';

class ComprehensionMeasurement {
  static bool shouldMeasure = false;

  static void attach(
    Future future, {
    required BuildContext context,
  }) {
    ComprehensionMeasurement.shouldMeasure = true;
    future.then((_) => ComprehensionMeasurement.measure(context));
  }

  static void measure(BuildContext context) {
    if (!shouldMeasure) return;
    // TODO(LeonHermann322): measure comprehension
    shouldMeasure = false;
  }
}
