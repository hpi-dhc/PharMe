import 'package:http/http.dart';

import '../module.dart';

Future<List<MedicationWithGuidelines>> fetchMedicationsWithGuidlines() async {
  final requestUri = annotationServerUrl('medications').replace(
    queryParameters: {
      'withGuidelines': 'true',
      'getGuidelines': 'true',
    },
  );

  final isOnline = await hasConnectionTo(requestUri.host);
  if (!isOnline) throw Exception();

  final response = await get(requestUri);
  if (response.statusCode != 200) throw Exception();

  return medicationsWithGuidelinesFromHTTPResponse(response);
}

Future<void> starCriticalMedications() async {
  final medications = await fetchMedicationsWithGuidlines();
  final criticalMedications = medications.filterCritical();
  UserData.instance.starredMediationIds =
      criticalMedications.map((medication) => medication.id).toList();
  await UserData.save();
}
