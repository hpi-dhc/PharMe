import '../module.dart';

class GeneModulatorList extends StatelessWidget {
  const GeneModulatorList({
    super.key,
    required this.geneName,
    this.onlyActiveDrugs = false,
    this.displayedDrug,
  });

  final String geneName;
  final bool onlyActiveDrugs;
  final String? displayedDrug;

  List<String> _getModulatorDrugNames(
    Map<String, Map<String, dynamic>>modulatorDefinition,
    String geneName,
  ) {
    final allModulatorDrugs = modulatorDefinition[geneName]!.keys.toList();
    if (onlyActiveDrugs) {
      final activeModulators = activeInhibitorsFor(
        geneName,
        drug: displayedDrug,
      );
      return allModulatorDrugs.filter(activeModulators.contains).toList();
    }
    return allModulatorDrugs;
  }

  List<Widget> _buildModulatorSublist(modulatorContentEntry) {
    final descriptionText = modulatorContentEntry.key;
    final modulatorDrugNames = modulatorContentEntry.value;
    if (modulatorDrugNames.isEmpty) return [SizedBox.shrink()];
    return [
      SizedBox(height: PharMeTheme.smallSpace),
      Text(
        descriptionText,
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
      SizedBox(height: PharMeTheme.smallSpace),
      UnorderedList(
        getDrugsWithBrandNames(
          modulatorDrugNames,
          capitalize: true,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final modulatorContent = {
      context.l10n.strong_inhibitors_description(geneName):
        _getModulatorDrugNames(strongDrugInhibitors, geneName),
      context.l10n.moderate_inhibitors_description(geneName):
        _getModulatorDrugNames(moderateDrugInhibitors, geneName),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
        modulatorContent.entries.flatMap(_buildModulatorSublist).toList(),
    );
  }
}