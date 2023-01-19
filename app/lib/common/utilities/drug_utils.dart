import 'package:http/http.dart';

import '../module.dart';

Future<List<Drug>> fetchDrugsWithGuidlines() async {
  final requestUri = anniUrl('drugs').replace(
    queryParameters: {
      'withGuidelines': 'true',
      'getGuidelines': 'true',
    },
  );

  final isOnline = await hasConnectionTo(requestUri.host);
  if (!isOnline) throw Exception();

  final response = await get(requestUri);
  if (response.statusCode != 200) throw Exception();

  return drugsWithGuidelinesFromHTTPResponse(response);
}

Future<void> starCriticalDrugs() async {
  final drugs = await fetchDrugsWithGuidlines();
  final criticalDrugs = drugs.filterCritical();
  UserData.instance.starredMediationIds =
      criticalDrugs.map((drug) => drug.id).toList();
  await UserData.save();
}
