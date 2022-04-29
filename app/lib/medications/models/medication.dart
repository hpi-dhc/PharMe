import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart';

part 'medication.freezed.dart';
part 'medication.g.dart';

@freezed
class Medication with _$Medication {
  const factory Medication(int id, String name, String description,
      String drugclass, String indication) = _Medication;
  factory Medication.fromJson(dynamic json) => _$MedicationFromJson(json);
}

List<Medication> medicationsFromHTTPResponse(Response resp) {
  final json = jsonDecode(resp.body) as List<dynamic>;
  return json.map<Medication>(Medication.fromJson).toList();
}
