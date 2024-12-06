import '../module.dart';

class PhenoconversionDisplayConfig {
  PhenoconversionDisplayConfig({
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

enum PhenoconversionDisplayType {
  user,
  expert 
}

extension on PhenoconversionDisplayType {
  PhenoconversionDisplayConfig getConfig(BuildContext context) {
    switch (this) {
      case PhenoconversionDisplayType.expert:
        return PhenoconversionDisplayConfig(
          partSeparator: ' ',
          userSalutation: context.l10n.inhibitor_third_person_salutation,
          userGenitive: context.l10n.inhibitor_third_person_salutation_genitive,
          useConsult: false,
        );
      default:
        return PhenoconversionDisplayConfig(
          partSeparator: '\n\n',
          userSalutation: context.l10n.inhibitor_direct_salutation,
          userGenitive: context.l10n.inhibitor_direct_salutation_genitive,
          useConsult: true,
        );
    }
  }
}

typedef PhenoconversionExplanationBuilder = dynamic Function(
  List<GenotypeResult> inhibitedGenotypes,
  String drugName,
  BuildContext? context,
); 

dynamic _getPhenoconversionExplanation({
  required Drug drug,
  required PhenoconversionExplanationBuilder explanationBuilder,
  BuildContext? context,
}) {
  final inhibitedGenotypes = getInhibitedGenotypesForDrug(drug);
  if (inhibitedGenotypes.isEmpty) return null;
  return explanationBuilder(inhibitedGenotypes, drug.name, context);
}

Widget? getUserPhenoconversionExplanation(Drug drug) {
  return _getPhenoconversionExplanation(
    drug: drug,
    explanationBuilder: (inhibitedGenotypes, drugName, _) =>
      PhenoconversionExplanation(
        inhibitedGenotypes: inhibitedGenotypes,
        drugName: drugName,
        displayType: PhenoconversionDisplayType.user,
      ),
  );
}

String? getExpertPhenoconversionExplanation(Drug drug, BuildContext context) {
  return _getPhenoconversionExplanation(
    drug: drug,
    explanationBuilder: (inhibitedGenotypes, drugName, context) =>
      getPhenoconversionExplanationString(
        context: context!,
        inhibitedGenotypes: inhibitedGenotypes,
        drugName: drugName,
        displayType: PhenoconversionDisplayType.expert,
      ),
    context: context,
  );
}

String? getPhenoconversionExplanationString({
  required BuildContext context,
  required List<GenotypeResult> inhibitedGenotypes,
  required String drugName,
  required PhenoconversionDisplayType displayType,
}) {
  final displayConfig = displayType.getConfig(context);
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
    this.displayType = PhenoconversionDisplayType.user,
  });

  final List<GenotypeResult> inhibitedGenotypes;
  final String? drugName;
  final PhenoconversionDisplayType displayType;

  @override
  Widget build(BuildContext context) {
    final displayConfig = displayType.getConfig(context);
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
    required PhenoconversionDisplayConfig displayConfig,
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
