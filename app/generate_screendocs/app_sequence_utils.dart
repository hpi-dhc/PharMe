import 'package:app/app.dart';
import 'package:app/common/module.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

Future<void> loadApp(WidgetTester tester) async {
  // Part before runApp in lib/main.dart
  await initServices();
  await updateGenotypeResults();
  // Load the app
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (context) => ActiveDrugs(),
      child: PharMeApp(),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> cleanupApp() async {
  // Part after runApp in lib/main.dart
  await cleanupServices();
}

Future<void> wait(int seconds) async {
  await Future.delayed(Duration(seconds: seconds));
}