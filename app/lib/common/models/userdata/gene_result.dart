import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';

part 'gene_result.g.dart';

@HiveType(typeId: 1)
@JsonSerializable()
class GeneResult {
  GeneResult({
    required this.gene,
    required this.genotype,
    required this.phenotype,
    required this.allelesTested,
  });

  factory GeneResult.fromJson(dynamic json) => _$GeneResultFromJson(json);
  Map<String, dynamic> toJson() => _$GeneResultToJson(this);

  @HiveField(0)
  String gene;

  @HiveField(1)
  String genotype;

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
