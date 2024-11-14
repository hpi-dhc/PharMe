import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../app.dart';
import '../../common/module.dart';

class LabProcessCanceled implements Exception {
  LabProcessCanceled();
}

class LabAuthenticationError implements Exception {
  LabAuthenticationError();
}

class Lab {
  Lab({
    required this.name,
  });

  String name;
  bool cancelPreparationInApp = false;
  bool preparationWasCanceled = false;

  String? preparationLoadingMessage() => null;

  String? preparationErrorMessage(BuildContext context) => null;
  
  Future<void> prepareDataLoad() async {}
  Future<(List<LabResult>, List<String>)> loadData() async {
    throw UnimplementedError();
  }

  Future<(List<LabResult>, List<String>)> fetchData(
    Uri dataUrl,
    {
      Map<String,String>? headers,
    }) async {
    final awaitingOpenFile =
      MetaData.instance.awaitingDeepLinkSharePublishUrl ?? false;
    final loggedIn = MetaData.instance.isLoggedIn ?? false;
    final needsConfirmation = !awaitingOpenFile || loggedIn;
    final context = PharMeApp.navigatorKey.currentContext;
    if (context == null && needsConfirmation) throw Exception();
    if (needsConfirmation) {
      final dialogTitle =  loggedIn
        ? 'Confirm data overwrite'
        : 'Received data';
      final dialogText = 'PharMe received data from another app. ${
        loggedIn
          ? 'Overwrite existing data?'
          : 'Continue if you want to import the data.'
      }';
      await showAdaptiveDialog(
        context: PharMeApp.navigatorKey.currentContext!,
        builder: (context) => DialogWrapper(
          title: dialogTitle,
          content: DialogContentText(dialogText),
          actions: [
            DialogAction(
              onPressed: () => Navigator.pop(context),
              text: context.l10n.action_cancel,
            ),
            DialogAction(
              onPressed: () => throw LabProcessCanceled(),
              text: context.l10n.action_understood,
            ),
          ],
        ),);
    }
    final response = await http.get(dataUrl, headers: headers);
    if (response.statusCode != 200) throw Exception();
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final labData = json['diplotypes'].map<LabResult>(
      LabResult.fromJson
    ).toList() as List<LabResult>;
    var activeDrugs = <String>[];
    if (json.containsKey('medications')) {
      activeDrugs = List<String>.from(json['medications']);
    }
    return (labData, activeDrugs);
  }
}
