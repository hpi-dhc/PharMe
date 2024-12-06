import '../module.dart';

// TODO(tamslo): if only one item, just print label and text afterwards
class GeneModulatorList {
  const GeneModulatorList({
    required this.geneName,
    this.onlyActiveDrugs = false,
    this.displayedDrug,
  });

  final String geneName;
  final bool onlyActiveDrugs;
  final String? displayedDrug;

  List<String> _filterActiveModulatorDrugNames(List<String> allModulatorDrugs) {
    final activeModulators = activeInhibitorsFor(
      geneName,
      drug: displayedDrug,
    );
    return allModulatorDrugs.filter(activeModulators.contains).toList();
  }

  List<String> _getModulatorDrugNames(
    BuildContext context,
    Map<String, Map<String, dynamic>>modulatorDefinition,
    String geneName,
  ) {
    final allModulatorDrugs = modulatorDefinition[geneName]!.keys.toList();
    final modulatorDrugNames = onlyActiveDrugs
      ? _filterActiveModulatorDrugNames(allModulatorDrugs)
      : allModulatorDrugs;
    return getDrugsWithBrandNames(
      modulatorDrugNames,
      capitalize: true,
      brandNamesPrefix: context.l10n.drug_item_brand_names.toLowerCase(),
    );
  }

  Map<String, List<String>> getContent(BuildContext context) {
    final contentDefinition = {
      context.l10n.strong_inhibitors_description: strongDrugInhibitors,
      context.l10n.moderate_inhibitors_description: moderateDrugInhibitors,
    };
    final content = <String, List<String>>{};
    for (final subdefinition in contentDefinition.entries) {
      final modulatorDefinition = subdefinition.value;
      final drugNames =
        _getModulatorDrugNames(context, modulatorDefinition, geneName);
      if (drugNames.isEmpty) continue;
      final getDescription = subdefinition.key;
      content[getDescription(geneName)] = drugNames;
    }
    return content;
  }

  String asString(BuildContext context, {String linePrefix = ''}) {
    final listString = StringBuffer();
    for (final modulatorContentEntry in getContent(context).entries) {
      final entryString = StringBuffer(modulatorContentEntry.key);
      for (final drugName in modulatorContentEntry.value) {
        entryString.write('\n$linePrefix- $drugName');
      }
      listString.write('\n$linePrefix$entryString');
    }
    return listString.toString();
  }

  GeneModulatorListWidget get widget => GeneModulatorListWidget(this);
}

class GeneModulatorListWidget extends StatelessWidget {
  const GeneModulatorListWidget(this.listDefinition);

  final GeneModulatorList listDefinition;

  List<Widget> _buildModulatorSublist(modulatorContentEntry) {
    final descriptionText = modulatorContentEntry.key;
    final modulatorDrugNames = modulatorContentEntry.value;
    return [
      SizedBox(height: PharMeTheme.smallSpace),
      Text(
        descriptionText,
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
      SizedBox(height: PharMeTheme.smallSpace),
      UnorderedList(modulatorDrugNames),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final modulatorContent = listDefinition.getContent(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
        modulatorContent.entries.flatMap(_buildModulatorSublist).toList(),
    );
  }
}