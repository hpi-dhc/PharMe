// Everything has to match literally. The final value is not a phenotype but
// the CPIC lookupkey value. If a user has multiple of the given drugs active,
// the topmost one will be used, i.e. the inhibitors should go from most to
// least severe.

// structure: gene symbol -> drug name -> overwriting lookupkey

import 'package:collection/collection.dart';

import '../../module.dart';

// Inhibit phenotype for gene by overwriting with poor metabolizer
const Map<String, Map<String, String>> strongDrugInhibitors = {
  'CYP2D6': {
    'bupropion': '0.0',
    'fluoxetine': '0.0',
    'paroxetine': '0.0',
    'quinidine': '0.0',
    'terbinafine': '0.0',
  },
};

// Inhibit phenotype for gene by adapting the activity score by a defined
// factor; not implement yet, currently only showing the warning (see
// https://github.com/hpi-dhc/PharMe/issues/667)
const Map<String, Map<String, double>> moderateDrugInhibitors = {
  'CYP2D6': {
    'abiraterone': 0.5,
    'cinacalcet': 0.5,
    'duloxetine': 0.5,
    'lorcaserin': 0.5,
    'mirabegron': 0.5,
  },
};

// Private helper functions

final _inhibitableGenes = List<String>.from(<String>{
  ...strongDrugInhibitors.keys,
  ...moderateDrugInhibitors.keys,
});

final _drugInhibitorsPerGene = {
  for (final gene in _inhibitableGenes) gene: [
    ...?strongDrugInhibitors[gene]?.keys,
    ...?moderateDrugInhibitors[gene]?.keys,
  ]
};

List<String> _inhibitorsFor(String gene) {
  return _drugInhibitorsPerGene[gene] ?? [];
}

bool _isInhibitorOfType(
  String drugName,
  Map<String, Map<String, dynamic>> inhibitorDefinition
) {
  final influencingDrugs = inhibitorDefinition.keys.flatMap(
    (gene) => inhibitorDefinition[gene]!.keys);
  return influencingDrugs.contains(drugName);
}

bool _isModerateInhibitor(String drugName) {
  return _isInhibitorOfType(drugName, moderateDrugInhibitors);
}

class _DisplayConfig {
  _DisplayConfig({
    required this.partSeparator,
    required this.userSalutation,
    required this.userGenitive,
    required this.useConsult,
  });

  final String partSeparator;
  final String userSalutation;
  final String userGenitive;
  final bool useConsult;
}

_DisplayConfig _getDisplayConfig(
  BuildContext context,
  { required bool userFacing }
) {
  final displayConfigs = <bool, _DisplayConfig>{
    true: _DisplayConfig(
      partSeparator: '\n\n',
      userSalutation: context.l10n.inhibitor_direct_salutation,
      userGenitive: context.l10n.inhibitor_direct_salutation_genitive,
      useConsult: true,
    ),
    false: _DisplayConfig(
      partSeparator: ' ',
      userSalutation: context.l10n.inhibitor_third_person_salutation,
      userGenitive: context.l10n.inhibitor_third_person_salutation_genitive,
      useConsult: false,
    ),
  };
  return displayConfigs[userFacing]!;
}

String _getPhenoconversionConsequence(
  BuildContext context,
  GenotypeResult genotypeResult,
  {
    String? drug,
    required _DisplayConfig displayConfig,
  }
) {
  final activeInhibitors = _activeInhibitorsFor(
    genotypeResult.gene,
    drug: drug,
  );
  return activeInhibitors.all(_isModerateInhibitor)
    ? context.l10n.inhibitors_consequence_not_adapted(
        genotypeResult.geneDisplayString,
        displayConfig.userGenitive,
      ).capitalize()
    : context.l10n.inhibitors_consequence_adapted(
        genotypeResult.geneDisplayString,
        genotypeResult.phenotype,
        displayConfig.userGenitive,
      ).capitalize();
}

String _getInhibitorsString(
  BuildContext context,
  GenotypeResult genotypeResult,
  { String? drug }
) {
  return context.l10n.inhibitors_tooltip(enumerationWithAnd(
    getDrugsWithBrandNames(_activeInhibitorsFor(
      genotypeResult.gene,
      drug: drug,
    )),
    context,
  ));
}

String _inhibitionTooltipText(
  BuildContext context,
  GenotypeResult genotypeResult,
  {
    String? drug,
    required _DisplayConfig displayConfig,
  }
) {
  final inhibitorsString = _getInhibitorsString(
    context,
    genotypeResult,
    drug: drug,
  );
  final consequence = _getPhenoconversionConsequence(
    context,
    genotypeResult,
    drug: drug,
    displayConfig: displayConfig,
  );
  return '$consequence${
    displayConfig.useConsult ? ' ${context.l10n.consult_text}' : ''
  }${displayConfig.partSeparator}$inhibitorsString';
}

Table _drugInteractionTemplate(
  BuildContext context,
  String tooltipText,
  _DisplayConfig displayConfig,
) {
  return buildTable([
    TableRowDefinition(
      drugInteractionIndicator,
      context.l10n.inhibitor_message(
        displayConfig.userSalutation,
        displayConfig.userGenitive,
      ),
      tooltip: tooltipText,
    )],
    boldHeader: false,
  );
}

List<String> _activeInhibitorsFor(String gene, { String? drug }) {
  return UserData.instance.activeDrugNames == null
    ? <String>[]
    : UserData.instance.activeDrugNames!.filter(
        (activeDrug) =>
          _inhibitorsFor(gene).contains(activeDrug) &&
          activeDrug != drug
      ).toList();
}

// Public helper functions

bool isInhibitor(String drugName) {
  var drugIsInhibitor = false;
  for (final gene in _drugInhibitorsPerGene.keys) {
    final influencingDrugs = _drugInhibitorsPerGene[gene];
    final originalLookup = UserData.lookupFor(gene, drug: drugName, useOverwrite: false);
    if (influencingDrugs!.contains(drugName) && originalLookup != '0.0') {
      drugIsInhibitor = true;
      break;
    }
  }
  return drugIsInhibitor;
}

bool isInhibited(
    GenotypeResult genotypeResult,
    { String? drug }
) {
  final activeInhibitors = _activeInhibitorsFor(
    genotypeResult.gene,
    drug: drug,
  );
  final originalPhenotype = genotypeResult.phenotypeDisplayString;
  final phenotypeCanBeInhibited =
    originalPhenotype.toLowerCase() != overwritePhenotype.toLowerCase();
  return activeInhibitors.isNotEmpty && phenotypeCanBeInhibited;
}

List<String> inhibitedGenes(Drug drug) {
  return _drugInhibitorsPerGene.keys.filter(
    (gene) => _drugInhibitorsPerGene[gene]!.contains(drug.name)
  ).toList();
}

MapEntry<String, String>? getOverwrittenLookup (
  String gene,
  { String? drug }
) {
  final inhibitors = strongDrugInhibitors[gene];
  if (inhibitors == null) return null;
  final lookup = inhibitors.entries.firstWhereOrNull((entry) {
    final isActiveInhibitor =
      UserData.instance.activeDrugNames?.contains(entry.key) ?? false;
    final wouldInhibitItself = drug == entry.key;
    return isActiveInhibitor && !wouldInhibitItself;
  });
  if (lookup == null) return null;
  return lookup;
}

String possiblyAdaptedPhenotype(
  GenotypeResult genotypeResult,
  { String? drug }
) {
  final originalPhenotype = genotypeResult.phenotypeDisplayString;
  if (!isInhibited(genotypeResult, drug: drug)) {
    return originalPhenotype;
  }
  final overwrittenLookup = getOverwrittenLookup(
    genotypeResult.gene,
    drug: drug,
  );
  if (overwrittenLookup == null) {
    return '$originalPhenotype$drugInteractionIndicator';
  }
  return '$overwritePhenotype$drugInteractionIndicator';
}

String inhibitionTooltipText(
  BuildContext context,
  List<GenotypeResult> genotypeResults,
  {
    String? drug,
    String partSeparator = '\n\n',
    bool userFacing = true,
  }
) {
  final inhibitedGenotypeResults = genotypeResults.filter(
    (genotypeResult) => isInhibited(genotypeResult, drug: drug)
  ).toList();
  var tooltipText = '';
  for (final (index, genotypeResult) in inhibitedGenotypeResults.indexed) {
    final separator = index == 0 ? '' : partSeparator;
    // ignore: use_string_buffers
    tooltipText = '$tooltipText$separator${
      _inhibitionTooltipText(
        context,
        genotypeResult,
        drug: drug,
        displayConfig: _getDisplayConfig(context, userFacing: userFacing),
      )
    }';
  }
  return tooltipText;
}

Table buildDrugInteractionInfo(
  BuildContext context,
  List<GenotypeResult> genotypeResults,
  {
    String? drug, 
  }
) {
  return _drugInteractionTemplate(
    context,
    inhibitionTooltipText(
      context,
      genotypeResults,
      drug: drug,
    ),
    _getDisplayConfig(context, userFacing: false),
  );
}
