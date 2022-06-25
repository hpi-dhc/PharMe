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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('TODO: Measure Comprehension'),
    ));
    shouldMeasure = false;
  }
}
