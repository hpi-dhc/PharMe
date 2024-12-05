import '../module.dart';

class _PhenoconversionDisplayConfig {
  _PhenoconversionDisplayConfig({
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

String getExpertPhenoconversionExplanation(
  BuildContext context,
  List<GenotypeResult> inhibitedGenotypes,
  String drugName,
) {
  final displayConfig = _PhenoconversionDisplayConfig(
    partSeparator: ' ',
    userSalutation: context.l10n.inhibitor_third_person_salutation,
    userGenitive: context.l10n.inhibitor_third_person_salutation_genitive,
    useConsult: false,
  );
  return inhibitedGenotypes.flatMap((genotypeResult) => [
    _getPhenoconversionDetailText(context, genotypeResult, drug: drugName, displayConfig: displayConfig),
    // TODO: get list
  ]).join(displayConfig.partSeparator);
}

class PhenoconversionExplanation extends StatelessWidget {
  const PhenoconversionExplanation({
    super.key,
    required this.inhibitedGenotypes,
    required this.drugName,
  });

  final List<GenotypeResult> inhibitedGenotypes;
  final String? drugName;

  @override
  Widget build(BuildContext context) {
    final displayConfig = _PhenoconversionDisplayConfig(
      partSeparator: '\n\n',
      userSalutation: context.l10n.inhibitor_direct_salutation,
      userGenitive: context.l10n.inhibitor_direct_salutation_genitive,
      useConsult: true,
    );
    return PrettyExpansionTile(
      title: buildTable([
        TableRowDefinition(
          drugInteractionIndicator,
          context.l10n.inhibitor_message(
            displayConfig.userSalutation,
            displayConfig.userGenitive,
          ),
        )],
        boldHeader: false,
      ),
      titlePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.all(PharMeTheme.mediumSpace),
      children: inhibitedGenotypes.flatMap(
        (genotypeResult) => [
          Text(_getPhenoconversionDetailText(
            context,
            genotypeResult,
            drug: drugName,
            displayConfig: displayConfig,
          )),
          GeneModulatorList(
            geneName: genotypeResult.gene,
            onlyActiveDrugs: true,
            displayedDrug: drugName,
          ),
        ]
      ).toList(),
    );
  }
}

String _getPhenoconversionDetailText(
  BuildContext context,
  GenotypeResult genotypeResult,
  {
    required String? drug,
    required _PhenoconversionDisplayConfig displayConfig,
  })
{
  final activeInhibitors = activeInhibitorsFor(
    genotypeResult.gene,
    drug: drug,
  );
  final consequence = activeInhibitors.all(isModerateInhibitor)
    ? context.l10n.inhibitors_consequence_not_adapted(
        genotypeResult.geneDisplayString,
        displayConfig.userGenitive,
      ).capitalize()
    : context.l10n.inhibitors_consequence_adapted(
        genotypeResult.geneDisplayString,
        genotypeResult.phenotypeDisplayString(context),
        displayConfig.userGenitive,
      ).capitalize();
  return '$consequence${
    displayConfig.useConsult ? ' ${context.l10n.consult_text}' : ''
  }';
}
