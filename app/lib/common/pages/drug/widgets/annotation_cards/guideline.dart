import 'package:url_launcher/url_launcher.dart';

import '../../../../module.dart';
import '../sub_header.dart';

class GuidelineAnnotationCard extends StatelessWidget {
  const GuidelineAnnotationCard(this.guideline);

  final Guideline guideline;

  @override
  Widget build(BuildContext context) {
    return RoundedCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildHeader(context),
          SizedBox(height: 12),
          _buildCard(context),
          SizedBox(height: 16),
          _buildSourcesSection(context),
          SizedBox(height: 12),
        ]),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Card(
        key: Key('annotationCard'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: guideline.annotations.warningLevel.color,
        child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(children: [
              Row(children: [
                Icon(guideline.annotations.warningLevel.icon,
                    color: PharMeTheme.onSurfaceText),
                SizedBox(width: 12),
                Flexible(
                  child: Text(
                    guideline.annotations.implication,
                    style: PharMeTheme.textTheme.bodyMedium,
                  ),
                )
              ]),
              SizedBox(height: 12),
              Text(
                guideline.annotations.recommendation,
                style: PharMeTheme.textTheme.bodyMedium,
              ),
            ])));
  }

  Widget _buildHeader(BuildContext context) {
    final geneDescriptions = guideline.lookupkey.keys.map((geneSymbol) =>
        '$geneSymbol (${UserData.instance.lookups![geneSymbol]!.phenotype})');
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SubHeader(context.l10n.drugs_page_your_genome),
      SizedBox(height: 12),
      Text(
        geneDescriptions.join(', '),
        style: PharMeTheme.textTheme.bodyLarge!,
      )
    ]);
  }

  Widget _buildSourcesSection(BuildContext context) {
    return Column(children: [
      SubHeader(
        context.l10n.drugs_page_header_further_info,
      ),
      SizedBox(height: 12),
      GestureDetector(
        onTap: () => _launchUrl(Uri.parse(guideline.cpicData.guidelineUrl)),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: PharMeTheme.onSurfaceColor,
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Flexible(
                child: Text(context.l10n.drugs_page_sources_cpic_description),
              ),
              Icon(Icons.chevron_right_rounded)
            ]),
          ),
        ),
      ),
    ]);
  }
}

Future<void> _launchUrl(Uri url) async {
  if (!await launchUrl(url)) throw Error();
}
