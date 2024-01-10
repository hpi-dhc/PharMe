import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'genotype.dart';

part 'gene_result.g.dart';

@HiveType(typeId: 1)
@JsonSerializable()
class GeneResult implements Genotype {
  GeneResult({
    required this.gene,
    required this.variant,
    required this.phenotype,
    required this.allelesTested,
  });

  factory GeneResult.fromJson(dynamic json) => _$GeneResultFromJson(json);
  Map<String, dynamic> toJson() => _$GeneResultToJson(this);

  @override
  @HiveField(0)
  String gene;

  @override
  @HiveField(1)
  @JsonKey(name: 'genotype')
  String variant;

  @HiveField(2)
  String phenotype;

  @HiveField(3)
  String allelesTested;
}

// assumes http reponse from lab server
List<GeneResult> geneResultsFromHTTPResponse(Response resp) {
  final json = jsonDecode(resp.body)['diplotypes'] as List<dynamic>;
  return json.map<GeneResult>(GeneResult.fromJson).toList();
}
