import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';

import '../models/drug/cached_drugs.dart';
import '../module.dart';

Future<void> updateCachedDrugs() async {
  if (UserData.instance.lookups == null) throw Exception();
  final isOnline = await hasConnectionTo(anniUrl().host);
  if (!isOnline && CachedDrugs.instance.version == null) {
    throw Exception();
  }

  final versionResponse = await get(anniUrl('version'));
  if (versionResponse.statusCode != 200) throw Exception();
  final version = AnniVersionResponse.fromJson(jsonDecode(versionResponse.body))
      .data
      .version;
  if (version == CachedDrugs.instance.version) return;

  final dataResponse = await get(anniUrl('data'));
  if (dataResponse.statusCode != 200) throw Exception();
  final data = AnniDataResponse.fromJson(jsonDecode(dataResponse.body)).data;
  final previousVersion = CachedDrugs.instance.version;
  CachedDrugs.instance.drugs = data.drugs;
  CachedDrugs.instance.version = data.version;
  await CachedDrugs.save();

  if (previousVersion != null) {
    final context = PharMeApp.navigatorKey.currentContext;
    if (context != null) {
      // ignore: use_build_context_synchronously
      await showCupertinoModalPopup(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(context.l10n.update_warning_title),
          content: Text(context.l10n.update_warning_body),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.action_continue),
            ),
          ],
        ),
      );
    }
  }
}
