import 'package:url_launcher/url_launcher.dart';

import '../../../common/module.dart';
import '../sub_header.dart';

class GuidelineAnnotationCard extends StatelessWidget {
  const GuidelineAnnotationCard(this.drug);

  final Drug drug;

  @override
  Widget build(BuildContext context) {
    return RoundedCard(
      innerPadding: const EdgeInsets.fromLTRB(
        PharMeTheme.mediumSpace,
        PharMeTheme.mediumSpace,
        PharMeTheme.mediumSpace,
        0
      ),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildHeader(context),
          SizedBox(height: 12),
          if (drug.userGuideline != null) ...[
            _buildCard(context),
            SizedBox(height: 8),
            Divider(color: PharMeTheme.borderColor),
            SizedBox(height: 8),
            _buildSourcesSection(context),
            SizedBox(height: 12),
          ]
          else ...[
            _buildCard(context),
            SizedBox(height: 16),
          ],
        ]),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    final upperCardText = drug.userGuideline?.annotations.implication ??
      context.l10n.drugs_page_no_guidelines_for_phenotype_implication(
        drug.name
      );
    final lowerCardText = drug.userGuideline?.annotations.recommendation ??
      context.l10n.drugs_page_no_guidelines_for_phenotype_recommendation;
    return Card(
        key: Key('annotationCard'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: drug.warningLevel.color,
        child: Padding(
            padding: EdgeInsets.all(12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(
                  drug.warningLevel.icon,
                  color: PharMeTheme.onSurfaceText,
                ),
                SizedBox(width: 12),
                Flexible(
                  child: Text(
                    upperCardText,
                    style: PharMeTheme.textTheme.bodyMedium,
                  ),
                )
              ]),
              SizedBox(height: 12),
              Text(
                lowerCardText,
                style: PharMeTheme.textTheme.bodyMedium,
              ),
            ])));
  }

  Widget _buildHeader(BuildContext context) {
    var headerContent = '';
    var headerStyle = PharMeTheme.textTheme.bodyLarge!;
    if (drug.userGuideline == null && drug.guidelines.isEmpty) {
      headerContent = context.l10n.drugs_page_guidelines_empty(drug.name);
      headerStyle = headerStyle.copyWith(fontStyle: FontStyle.italic);
    } else {
      final genes = drug.userGuideline?.lookupkey.keys ??
        drug.guidelines.first.lookupkey.keys;
      final geneDescriptions = genes.map((geneSymbol) {
        final phenotypeInformation = UserData.phenotypeFor(
          geneSymbol,
          context,
          drug: drug.name,
        );
        var description = '$geneSymbol: ${phenotypeInformation.phenotype}';
        if (phenotypeInformation.adaptionText.isNotNullOrBlank) {
          description = '$description (${phenotypeInformation.adaptionText})';
        }
        return description;
      });
      headerContent = geneDescriptions.join('\n');
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SubHeader(context.l10n.drugs_page_your_genome),
      SizedBox(height: 12),
      Text(
        headerContent,
        style: headerStyle,
      ),
    ]);
  }

  Widget _buildSourcesSection(BuildContext context) {
    // pipes are illegal characters in URLs so please
    // - forgive the cheap hack or
    // - refactor by making a custom object and defining equality for it :)
    final sources = drug.userGuideline!.externalData
        .map((data) => '${data.source}|${data.guidelineUrl}')
        .toSet();
    return Column(children: [
      SubHeader(
        context.l10n.drugs_page_header_further_info,
      ),
      SizedBox(height: 12),
      ...sources.map(
        (source) => GestureDetector(
          onTap: () => _launchUrl(Uri.parse(source.split('|')[1])),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: PharMeTheme.onSurfaceColor,
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Flexible(
                  child: Text(context.l10n
                      .drugs_page_sources_description(source.split('|')[0])),
                ),
                Icon(Icons.chevron_right_rounded)
              ]),
            ),
          ),
        ),
      ),
    ]);
  }
}

Future<void> _launchUrl(Uri url) async {
  if (!await launchUrl(url)) throw Error();
}
