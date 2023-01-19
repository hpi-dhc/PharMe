import 'dart:convert';
import 'package:http/http.dart';

import '../models/anni_response.dart';
import '../models/drug/cached_drugs.dart';
import '../module.dart';

Future<void> updateCachedDrugs() async {
  final isOnline = await hasConnectionTo(anniUrl().host);
  if (!isOnline && CachedDrugs.instance.version == null) {
    throw Exception();
  }

  final versionResponse = await get(anniUrl('version'));
  if (versionResponse.statusCode != 200) throw Exception();
  final version =
      (jsonDecode(versionResponse.body) as AnniVersionResponse).data.version;
  if (version == CachedDrugs.instance.version) return;

  final dataResponse = await get(anniUrl('data'));
  if (dataResponse.statusCode != 200) throw Exception();
  final drugs =
      (jsonDecode(versionResponse.body) as AnniDataResponse).data.drugs;
  CachedDrugs.instance.drugs = drugs.filterUserGuidelines();
  await CachedDrugs.save();
}
