import 'package:freezed_annotation/freezed_annotation.dart';

import 'medication.dart';

part 'medications_group.freezed.dart';
part 'medications_group.g.dart';

@freezed
class MedicationsGroup with _$MedicationsGroup {
  const factory MedicationsGroup(
      int id, String name, List<Medication> medications) = _MedicationsGroup;
  factory MedicationsGroup.fromJson(Map<String, dynamic> json) =>
      _$MedicationsGroupFromJson(json);
}
