import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';

part 'diplotype.g.dart';

@HiveType(typeId: 1)
@JsonSerializable()
class Diplotype {
  Diplotype({
    required this.gene,
    required this.resultType,
    required this.genotype,
    required this.phenotype,
    required this.allelesTested,
  });

  factory Diplotype.fromJson(dynamic json) => _$DiplotypeFromJson(json);
  Map<String, dynamic> toJson() => _$DiplotypeToJson(this);

  @HiveField(0)
  String gene;

  @HiveField(1)
  String resultType;

  @HiveField(2)
  String genotype;

  @HiveField(3)
  String phenotype;

  @HiveField(4)
  String allelesTested;
}

extension ValidDiplotypes on List<Diplotype> {
  List<Diplotype> filterValidDiplotypes() {
    final acceptedResultTypes = ['Diplotype'];
    return where((element) => acceptedResultTypes.contains(element.resultType))
        .toList();
  }
}

// assumes http reponse from lab server
List<Diplotype> diplotypesFromHTTPResponse(Response resp) {
  final json = jsonDecode(resp.body)['diplotypes'] as List<dynamic>;
  return json.map<Diplotype>(Diplotype.fromJson).toList();
}
