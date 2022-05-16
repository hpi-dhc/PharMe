import 'package:url_launcher/url_launcher.dart';

import '../../common/module.dart';

class MedicationDetailsPage extends StatelessWidget {
  const MedicationDetailsPage({required this.medication}) : super();

  final MedicationWithGuidelines medication;

  @override
  Widget build(BuildContext context) {
    return RoundedCard(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
      child: Column(
        children: [
          Text(medication.name),
          if (medication.drugclass != null) Text(medication.drugclass!),
          Row(
            children: [
              Icon(Icons.warning),
              Flexible(
                child: Text(context.l10n.medications_details_page_disclaimer),
              ),
            ],
          ),
          Row(
            children: [
              Flexible(
                child: Text(context
                    .l10n.medications_details_page_header_guideline
                    .toUpperCase()),
              ),
              Icon(Icons.help_outline),
            ],
          ),
          Expanded(
            child: RoundedCard(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(medication
                            .guidelines[0].genePhenotype.geneSymbol.name),
                        if (medication.guidelines[0].cpicClassification != null)
                          Text(medication.guidelines[0].cpicClassification!),
                        Icon(Icons.help_outline),
                      ],
                    ),
                    if (medication.guidelines[0].implication != null)
                      Row(
                        children: [
                          Icon(Icons.info_outline),
                          Flexible(
                            child: Text(medication.guidelines[0].implication!),
                          ),
                        ],
                      ),
                    Card(
                      color: Colors.red[200],
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(context.l10n
                                    .medications_details_page_header_recommendation
                                    .toUpperCase()),
                              ),
                              Icon(Icons.warning),
                            ],
                          ),
                          Text(medication.guidelines[0].recommendation!),
                        ]),
                      ),
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Text(context
                              .l10n.medications_details_page_header_further_info
                              .toUpperCase()),
                        ),
                        Icon(Icons.help_outline),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => _launchPharmGkbUrl(medication.pharmgkbId),
                      child: Card(
                        color: Colors.blue[200],
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              Text('PharmGKB'),
                              Flexible(
                                child: Text(
                                    'Curated pharmacogenetic studies for this drug-gene reaction'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _launchPharmGkbUrl(String? id) async {
  var url = 'https://pharmgkb.org';

  // redirect to specific pharmgkb page if id is present
  if (id != null) {
    url += '/chemical/$id/clinicalAnnotation';
  }

  await _launchUrl(Uri.parse(url));
}

Future<void> _launchUrl(Uri url) async {
  if (!await launchUrl(url)) throw Error();
}
