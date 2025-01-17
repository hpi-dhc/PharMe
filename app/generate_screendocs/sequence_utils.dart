import 'package:app/app.dart';
import 'package:app/common/module.dart';
import 'package:app/drug/widgets/module.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart'; 

Future<void> loadApp(WidgetTester tester) async {
  // Part before runApp in lib/main.dart
  await initServices();
  await maybeUpdateGenotypeResults();
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

Future<void> settleAndWait(WidgetTester tester, int seconds) async {
  await tester.pumpAndSettle();
  await Future.delayed(Duration(seconds: seconds));
}

Future<void> _enterText(WidgetTester tester, Finder finder, String text) async {
  var buildingSearchTerm = '';
  for (final character in text.characters) {
    // ignore: use_string_buffers
    buildingSearchTerm = '$buildingSearchTerm$character';
    await tester.enterText(finder, buildingSearchTerm);
  }
}

Future<void> _clearText(WidgetTester tester, Finder finder, String text) async {
  var unbuildingSearchTerm = text;
  for (final character in text.characters.reversed) {
    // ignore: use_string_buffers
    unbuildingSearchTerm = unbuildingSearchTerm.removeSuffix(character);
    await tester.enterText(finder, unbuildingSearchTerm);
  }
}

Future<void> enterUsername(WidgetTester tester, String username) async {
  await _enterText(tester, find.byType(TextField).first, username);
}

Future<void> enterPassword(WidgetTester tester, String password) async {
  await _enterText(tester, find.byType(TextField).last, password);
}

Future<void> searchDrug(WidgetTester tester, String drug) async {
  await _enterText(tester, find.byType(CupertinoSearchTextField).last, drug);
}

Future<void> clearDrugSearch(WidgetTester tester, String drug) async {
  await _clearText(tester, find.byType(CupertinoSearchTextField).last, drug);
}

Future<void> finishTextInput(WidgetTester tester) async {
  await tester.testTextInput.receiveAction(TextInputAction.done);
}

Future<void> tapButton(WidgetTester tester, String label) async {
   await tester.tap(find.bySemanticsLabel(label).first);
}

Future<void> tapFullWidthButton(WidgetTester tester) async {
  await tester.tap(find.byType(FullWidthButton).first);
}

Finder _findText(String text) {
  final exactMatch = find.text(text, skipOffstage: false).first;
  if (exactMatch.hasFound) return exactMatch;
  return find.textContaining(text, skipOffstage: false).first;
}

Future<void> tapText(WidgetTester tester, String text) async {
  await tester.tap(_findText(text));
}

Future<void> jumpToText(WidgetTester tester, String text) async {
  final target = find.text(text, skipOffstage: false).first;
  await tester.ensureVisible(target);
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

Future<void> interactWithDrugInSelection(
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

Future<void> interactWithDrugInSearch(
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
    itemKey: 'drug-card-${drug.toLowerCase()}',
    listKey: 'drug-search',
    itemType: DrugCard,
    scroll: scroll,
    tap: tap,
    raiseException: raiseException,
  );
}

Future<void> useBottomNavigation(
  WidgetTester tester,
  String destination,
) async {
  await tester.tap(find.descendant(
    of: find.byType(BottomNavigationBar),
    matching: find.text(destination),
  ).first);
}

Future<void> changeDrugStatus(
  WidgetTester tester,
  String drug,
  String activity,
) async {
  await tester.tap(
    find.byType(Switch).first,
  );
}

Future<void> tapFirstFaqItem(WidgetTester tester) async {
  await tester.tap(
    find.descendant(
      of: find.byType(ExpansionTile).first,
      matching: find.byType(Icon),
    ),
  );
}

Future<void> tapDrugSearchTooltip(WidgetTester tester) async {
  await tester.tap(find.descendant(
    of: find.byType(DrugSearch),
    matching: find.byType(TooltipIcon),
  ).first);
}

Future<void> toggleNthWarningLevel(WidgetTester tester, int n) async {
  // We are basically testing :shrug:
  // ignore: invalid_use_of_visible_for_testing_member
  await tester.tap(find.byType(WarningLevelFilterChip).at(n));
}

Future<void> selectDialogAction(WidgetTester tester) async {
  await tester.tap(find.byType(DialogAction));
}

Future<void> openDrugFilters(WidgetTester tester) async {
  await tester.tap(find.ancestor(
    of: find.byIcon(Icons.filter_list),
    matching: find.byType(IconButton),
  ));
}

Future<void> closeDrugFilters(WidgetTester tester) async {
  await tester.tapAt(Offset(0, 0));
}

// Sometimes tester.pageBack is not working, then can use this
Future<void> tapBackButton(WidgetTester tester) async {
  await tester.tap(find.byType(IconButton).first,warnIfMissed: false);
}
