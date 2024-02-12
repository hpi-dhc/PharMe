import 'genotype.dart';

class LookupInformation implements Genotype {
  LookupInformation({
    required this.gene,
    required this.phenotype,
    required this.variant,
    required this.lookupkey,
  });

  factory LookupInformation.fromJson(dynamic json) {
    return LookupInformation(
        gene: json['genesymbol'] as String,
        variant: json['diplotype'] as String,
        phenotype: json['generesult'] as String,
        lookupkey: json['lookupkey'][json['genesymbol']] as String,
    );
  }

  @override
  String gene;
  @override
  String variant;
  String phenotype;
  String lookupkey;
}
