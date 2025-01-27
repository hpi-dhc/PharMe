// Clicks though most parts of the app and creates screenshots (based on
// https://dev.to/mjablecnik/take-screenshot-during-flutter-integration-tests-435k)
// and screencasts; also outputs timestamp logs for cutting smaller screencasts

import 'dart:io';

import 'package:app/app.dart';
import 'package:app/common/module.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

Future<void> takeScreenshot(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding,
  String fileName
) async {
  if (Platform.isAndroid) {
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
  }
  await binding.takeScreenshot(fileName);
}

Future<void> logTimeStamp(
  WidgetTester tester,
  String prefix,
  String description,
) async {
  await tester.pumpAndSettle();
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  // ignore: avoid_print
  print('$prefix$timestamp $description');
  await _waitAndSettle(tester, 1);
}

Future<void> beginPart(
  WidgetTester tester,
  String timestampPrefix,
  String description,
) async{
  await logTimeStamp(tester, timestampPrefix, description);
}

Future<void> endPart(
  WidgetTester tester,
  String timestampPrefix,
  String description,
) async {
  await logTimeStamp(tester, timestampPrefix, description);
}

void main() {
  group('click through the app and create screencasts', () {
    final binding = IntegrationTestWidgetsFlutterBinding();
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    testWidgets('take screencast', (tester) async {
      const username = String.fromEnvironment('TEST_USER');
      const password = String.fromEnvironment('TEST_PASSWORD');
      const timestampPrefix = String.fromEnvironment('TIMESTAMP_PREFIX');

      await _loadApp(tester);

      const acceptLoginDescription = '01_accept_and_login';
      const onboardingDescription = '02_onboarding';
      const drugSelectionDescription = '03_drug_selection';
      const tutorialDescription = '04_tutorial';
      const bottomNavigationDescription = '05_bottom_navigation_loopable';
      const drugSearchFilterDescription = '06_drug_search_and_filter_loopable';
      const ibuprofenDescription = '07_ibuprofen_loopable';
      const reportCyp2c9Description = '08_report_and_cyp2c9_loopable';
      const faqMoreDescription = '09_faq_and_more_loopable';
      const deleteDataDescription = '10_delete_data';

      await beginPart(
        tester,
        timestampPrefix,
        acceptLoginDescription,
      );
      await _waitAndSettle(tester, 1);
      await takeScreenshot(tester, binding, 'accept-terms');
      await _tapButton(tester, 'Continue');
      await _waitAndSettle(tester, 2);
      await _enterUsername(tester, username);
      await _waitAndSettle(tester, 1);
      await _enterPassword(tester, password);
      await tester.pumpAndSettle();
      await takeScreenshot(tester, binding, 'login');
      await _tapFullWidthButton(tester);
      await _waitAndSettle(tester, 1);
      await endPart(tester, timestampPrefix, acceptLoginDescription);

      await beginPart(
        tester,
        timestampPrefix,
        onboardingDescription,
      );
      const onboardingWaitingTime = 1;
      await _waitAndSettle(tester, onboardingWaitingTime);
      await takeScreenshot(tester, binding, 'onboarding-1');
      await _tapButton(tester, 'Next');
      await _waitAndSettle(tester, onboardingWaitingTime);
      await takeScreenshot(tester, binding, 'onboarding-2');
      await _tapButton(tester, 'Next');
      await _waitAndSettle(tester, onboardingWaitingTime);
      await takeScreenshot(tester, binding, 'onboarding-3');
      await _tapButton(tester, 'Next');
      await _waitAndSettle(tester, onboardingWaitingTime);
      await takeScreenshot(tester, binding, 'onboarding-4');
      await _tapButton(tester, 'Next');
      await _waitAndSettle(tester, onboardingWaitingTime);
      await takeScreenshot(tester, binding, 'onboarding-5');
      await _tapButton(tester, 'Get started');
      await _waitAndSettle(tester, 1);
      await endPart(tester, timestampPrefix, onboardingDescription);

      await beginPart(tester, timestampPrefix, drugSelectionDescription);
      await _waitAndSettle(tester, 2);
      await takeScreenshot(tester, binding, 'drug-selection-intro');
      await _tapButton(tester, 'Continue');
      await _waitAndSettle(tester, 1);
      await _searchDrug(tester, 'Ibu');
      await _waitAndSettle(tester, 1);
      await _interactWithDrugInSelection(
        tester,
        'Ibuprofen',
        scroll: false,
        tap: true,
      );
      await _waitAndSettle(tester, 1);
      await _clearDrugSearch(tester);
      await _waitAndSettle(tester, 1);
      await takeScreenshot(tester, binding, 'drug-selection');
      await _tapFullWidthButton(tester);
      await _waitAndSettle(tester, 1);
      await endPart(tester, timestampPrefix, drugSelectionDescription);

      await beginPart(tester, timestampPrefix, tutorialDescription);
      const tutorialWaitingTime = 1;
      await Future.delayed(Duration(seconds: tutorialWaitingTime));
      await takeScreenshot(tester, binding, 'tutorial-1');
      await _tapButton(tester, 'Continue');
      await _waitAndSettle(tester, tutorialWaitingTime);
      await takeScreenshot(tester, binding, 'tutorial-2');
      await _tapButton(tester, 'Continue');
      await _waitAndSettle(tester, tutorialWaitingTime);
      await takeScreenshot(tester, binding, 'tutorial-3');
      await _tapButton(tester, 'Continue');
      await _waitAndSettle(tester, tutorialWaitingTime);
      await takeScreenshot(tester, binding, 'tutorial-4');
      await _tapButton(tester, 'Continue');
      await _waitAndSettle(tester, tutorialWaitingTime);
      await takeScreenshot(tester, binding, 'tutorial-5');
      await _tapButton(tester, 'Finish');
      await _waitAndSettle(tester, 1);
      await takeScreenshot(tester, binding, 'setup-complete');
      await _selectDialogAction(tester);
      await _waitAndSettle(tester, 1);
      await endPart(tester, timestampPrefix, tutorialDescription);

      await beginPart(tester, timestampPrefix, bottomNavigationDescription);
      await _waitAndSettle(tester, 1);
      await _useBottomNavigation(tester, 'Genes');
      await _waitAndSettle(tester, 1);
      await _useBottomNavigation(tester, 'FAQ');
      await _waitAndSettle(tester, 1);
      await _useBottomNavigation(tester, 'More');
      await _waitAndSettle(tester, 1);
      await _useBottomNavigation(tester, 'Medications');
      await _waitAndSettle(tester, 0);
      await endPart(tester, timestampPrefix, bottomNavigationDescription);

      const toggledWarningLevelIndex = 3; // missing data
      await beginPart(tester, timestampPrefix, drugSearchFilterDescription);
      await _waitAndSettle(tester, 1);
      await takeScreenshot(tester, binding, 'drug-search');
      await _openDrugFilters(tester);
      await _waitAndSettle(tester, 1);
      await takeScreenshot(tester, binding, 'drug-search-filter');
      await _toggleNthWarningLevel(tester, toggledWarningLevelIndex);
      await _waitAndSettle(tester, 2);
      await _toggleNthWarningLevel(tester, toggledWarningLevelIndex);
      await _waitAndSettle(tester, 1);
      await _closeDrugFilters(tester);
      await _waitAndSettle(tester, 0);
      await endPart(tester, timestampPrefix, drugSearchFilterDescription);
      
      await beginPart(tester, timestampPrefix, ibuprofenDescription);
      await _waitAndSettle(tester, 1);
      await _tapText(tester, 'Ibuprofen');
      await _waitAndSettle(tester, 1);
      await takeScreenshot(tester, binding, 'ibuprofen');
      await _changeDrugStatus(tester, 'Ibuprofen', 'inactive');
      await _waitAndSettle(tester, 2);
      try {
        await _changeDrugStatus(tester, 'Ibuprofen', 'active');   
        await _waitAndSettle(tester, 2);     
      } catch (e) {
        // ignore: avoid_print
        print(
          '🚨 Could not activate Ibuprofen again; video will not be'
          'loopable'
        );
      }
      await tester.pageBack();
      await _waitAndSettle(tester, 1);
      await endPart(tester, timestampPrefix, ibuprofenDescription);

      await _waitAndSettle(tester, 1);
      await _useBottomNavigation(tester, 'Genes');
      await _waitAndSettle(tester, 2);

      await beginPart(tester, timestampPrefix, reportCyp2c9Description);
      await _waitAndSettle(tester, 1);
      await takeScreenshot(tester, binding, 'gene-report-current');
      await _toggleNonCurrentList(tester);
      await _waitAndSettle(tester, 1);
      await takeScreenshot(tester, binding, 'gene-report-all');
      await _toggleNonCurrentList(tester, expectExpanded: true);
      await _waitAndSettle(tester, 1);
      await _tapGeneCard(tester, 'CYP2C9');
      await _waitAndSettle(tester, 2);
      await takeScreenshot(tester, binding, 'cyp2c9');
      await _toggleNonCurrentList(tester);
      await _waitAndSettle(tester, 2);
      await takeScreenshot(tester, binding, 'cyp2c9-expanded');
      await _toggleNonCurrentList(tester, expectExpanded: true);
      await _waitAndSettle(tester, 0);
      await tester.pageBack();
      await _waitAndSettle(tester, 1);
      await endPart(tester, timestampPrefix, reportCyp2c9Description);

      await _waitAndSettle(tester, 1);
      await _useBottomNavigation(tester, 'FAQ');
      await _waitAndSettle(tester, 1);
      await takeScreenshot(tester, binding, 'faq');

      await beginPart(tester, timestampPrefix, faqMoreDescription);
      await _waitAndSettle(tester, 1);
      await _tapFirstFaqItem(tester);
      await _waitAndSettle(tester, 1);
      await takeScreenshot(tester, binding, 'faq-first-item');
      await _tapFirstFaqItem(tester);
      await _waitAndSettle(tester, 1);
      await _useBottomNavigation(tester, 'More');
      await _waitAndSettle(tester, 3);
      await takeScreenshot(tester, binding, 'more');
      await _tapText(tester, 'Contact us', selectLast: true);
      await _waitAndSettle(tester, 2);
      await _selectDialogAction(tester, selectFirst: true);
      await _waitAndSettle(tester, 0);
      await _useBottomNavigation(tester, 'FAQ');
      await _waitAndSettle(tester, 1);
      await endPart(tester, timestampPrefix, faqMoreDescription);


      await beginPart(tester, timestampPrefix, deleteDataDescription);
      await _useBottomNavigation(tester, 'More');
      await tester.pumpAndSettle();
      await _tapText(tester, 'Delete app data');
      await tester.pumpAndSettle();
      await takeScreenshot(tester, binding, 'delete-app-data');
      await _selectDialogAction(tester, selectFirst: true);
      await tester.pumpAndSettle();
      await endPart(tester, timestampPrefix, deleteDataDescription);

      await _cleanupApp();
    });
  });
}

Future<void> _loadApp(WidgetTester tester) async {
  // Part before runApp in lib/main.dart
  await initServices();
  // Load the app
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ActiveDrugs()),
        ChangeNotifierProvider(create: (context) => InactivityTimer()),
      ],
      child: PharMeApp(),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _cleanupApp() async {
  // Part after runApp in lib/main.dart
  await cleanupServices();
}

Future<void> _waitAndSettle(WidgetTester tester, int seconds) async {
  await tester.pumpAndSettle();
  await Future.delayed(Duration(seconds: seconds));
  await tester.pumpAndSettle();
}

Future<void> _enterText(WidgetTester tester, Finder finder, String text) async {
  // Please note: apparently, this does not actually open the keyboard in the
  // simulator (which is fine I guess)
  await tester.showKeyboard(finder);
  await tester.pump();
  var buildingSearchTerm = '';
  for (final character in text.characters) {
    // ignore: use_string_buffers
    buildingSearchTerm = '$buildingSearchTerm$character';
    await tester.enterText(finder, buildingSearchTerm);
    await tester.pump();
  }
  await _finishTextInput(tester);
}

Future<void> _enterUsername(WidgetTester tester, String username) async {
  await _enterText(tester, find.byType(TextField).first, username);
}

Future<void> _enterPassword(WidgetTester tester, String password) async {
  await _enterText(tester, find.byType(TextField).last, password);
}

Future<void> _searchDrug(WidgetTester tester, String drug) async {
  await _enterText(tester, find.byType(CupertinoSearchTextField).last, drug);
}

Future<void> _clearDrugSearch(WidgetTester tester) async {
  await tester.tap(find.descendant(
    of: find.byType(CupertinoSearchTextField).first,
    matching: find.byType(Icon),
  ).last);
}

Future<void> _finishTextInput(WidgetTester tester) async {
  await tester.testTextInput.receiveAction(TextInputAction.done);
}

Future<void> _tapButton(WidgetTester tester, String label) async {
   await tester.tap(find.bySemanticsLabel(label).first);
}

Future<void> _toggleNonCurrentList(
  WidgetTester tester,
  { bool expectExpanded = false }
) async {
  final expectedIcon = expectExpanded
    ? Icons.arrow_drop_up
    : Icons.arrow_drop_down;
  await tester.tap(
    find.ancestor(
      of: find.byIcon(expectedIcon, skipOffstage: false),
      matching: find.byType(ResizedIconButton, skipOffstage: false),
    ).last,
  );
}

Future<void> _tapFullWidthButton(WidgetTester tester) async {
  await tester.tap(find.byType(FullWidthButton).first);
}

Finder _findText(String text, {bool selectLast = false}) {
  final exactMatch = find.text(text, skipOffstage: false);
  if (exactMatch.hasFound) {
    return selectLast
      ? exactMatch.last
      : exactMatch.first;
  }
  final fuzzyMatch = find.textContaining(text, skipOffstage: false);
  return selectLast ? fuzzyMatch.last : fuzzyMatch.first;
}

Future<void> _tapText(
  WidgetTester tester,
  String text,
  {bool selectLast = false}
) async {
  await tester.tap(_findText(text, selectLast: selectLast));
}

Future<void> _tapGeneCard(
  WidgetTester tester,
  String gene,
  { String keyPostfix = 'current-medications' }
) async {
  final geneCard = find.byKey(
    Key('gene-card-$gene-$keyPostfix'),
    skipOffstage: false,
  );
  await tester.tap(geneCard);
}

// This is a bit hacky, as only some list items can be found currently
// (not sure why); therefore, the script needs to select one of those.
// If the interaction could not be executed, a list of available items is
// printed.
Future<void> _interactWithDrugListItem(
  WidgetTester tester,
  {
    required String itemKey,
    required String listKey,
    required Type itemType,
    required bool scroll,
    required bool tap,
    required bool raiseException,
  }
) async {
  final listFinder = find.byKey(Key(listKey), skipOffstage: false);
  final itemFinder = find.descendant(
    of: listFinder,
    matching: find.byKey(Key(itemKey), skipOffstage: false),
    skipOffstage: false,
  );
  final item = itemFinder.first;
  try {
    if (scroll) {
      final list = listFinder.first;
      await tester.dragUntilVisible(item, list, Offset(0, -0.1));
    }
    if (tap) {
      await tester.tap(item);
    }
  } catch (e) {
    var errorMessage = '🚨 Could not drag drug list';
    if (!raiseException) errorMessage += '\n  Error: ${e.toString()}\n';
    // ignore: avoid_print
    print(errorMessage);
    var contextDetails = 'Context details:\n'
      '  With item finder: ${itemFinder.toString()}';
    if (scroll) {
      contextDetails += '\n  With list finder: ${listFinder.toString()}\n';
    }
    // ignore: avoid_print
    print(contextDetails);
    // ignore: avoid_print
    print('Available drug items:');
    final availableItems = find.descendant(
      of: listFinder,
      matching: find.byType(itemType, skipOffstage: false),
      skipOffstage: false,
    );
    availableItems.evaluate();
    // ignore: avoid_function_literals_in_foreach_calls
    availableItems.found.forEach(
      // ignore: avoid_print
      (element) => print('  ${element.toString()}')
    );
    if (raiseException) rethrow;
  }
}

Future<void> _interactWithDrugInSelection(
  WidgetTester tester,
  String drug,
  {
    required bool scroll,
    required bool tap,
    bool raiseException = true,
  }
) async {
  await _interactWithDrugListItem(
    tester,
    itemKey: 'other-drug-selection-tile-${drug.toLowerCase()}',
    listKey: 'drug-selection',
    itemType: SwitchListTile,
    scroll: scroll,
    tap: tap,
    raiseException: raiseException,
  );
}

Future<void> _useBottomNavigation(
  WidgetTester tester,
  String destination,
) async {
  await tester.tap(find.descendant(
    of: find.byType(BottomNavigationBar),
    matching: find.text(destination),
  ).first);
}

Future<void> _changeDrugStatus(
  WidgetTester tester,
  String drug,
  String activity,
) async {
  await tester.tap(
    find.byType(Switch).first,
  );
}

Future<void> _tapFirstFaqItem(WidgetTester tester) async {
  await tester.tap(
    find.descendant(
      of: find.byType(ExpansionTile).first,
      matching: find.byType(Icon),
    ),
  );
}

Future<void> _toggleNthWarningLevel(WidgetTester tester, int n) async {
  // We are basically testing :shrug:
  // ignore: invalid_use_of_visible_for_testing_member
  await tester.tap(find.byType(WarningLevelFilterChip).at(n));
}

Future<void> _selectDialogAction(
  WidgetTester tester,
  {bool selectFirst = false}
) async {
  final actions = find.byType(DialogAction, skipOffstage: false);
  final action = selectFirst ? actions.first : actions.last;
  await tester.tap(action);
}

Future<void> _openDrugFilters(WidgetTester tester) async {
  await tester.tap(find.ancestor(
    of: find.byIcon(Icons.filter_list),
    matching: find.byType(IconButton),
  ));
}

Future<void> _closeDrugFilters(WidgetTester tester) async {
  await tester.tapAt(Offset(0, 0));
}
