import 'package:url_launcher/url_launcher.dart';

import '../common/module.dart';

class MedicationPage extends StatelessWidget {
  const MedicationPage({required this.medication}) : super();

  final MedicationWithGuidelines medication;

  @override
  Widget build(BuildContext context) {
    return RoundedCard(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MedicationsPageMedicationHeader(
            name: medication.name,
            drugclass: medication.drugclass!,
          ),
          MedicationsPageDisclaimer(),
          HeaderGeneric(
            title: context.l10n.medications_details_page_header_guideline,
            secondary: Icon(Icons.help_outline),
            uppercase: true,
          ),
          ClinicalAnnotationCard(medication: medication),
        ],
      ),
    );
  }
}

class HeaderGeneric extends StatelessWidget {
  const HeaderGeneric({
    required this.title,
    required this.secondary,
    this.uppercase = false,
    this.alignment = MainAxisAlignment.start,
  });

  final String title;
  final Widget secondary;
  final bool uppercase;
  final MainAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      children: [
        Flexible(child: Text(uppercase ? title.toUpperCase() : title)),
        secondary,
      ],
    );
  }
}

class MedicationsPageMedicationHeader extends StatelessWidget {
  const MedicationsPageMedicationHeader({
    required this.name,
    required this.drugclass,
  });

  final String name;
  final String drugclass;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name),
        Text(drugclass),
      ],
    );
  }
}

class MedicationsPageDisclaimer extends StatelessWidget {
  const MedicationsPageDisclaimer();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.warning),
        Flexible(
          child: Text(context.l10n.medications_details_page_disclaimer),
        ),
      ],
    );
  }
}

class ClinicalAnnotationCard extends StatelessWidget {
  const ClinicalAnnotationCard({required this.medication});

  final MedicationWithGuidelines medication;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: RoundedCard(
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              HeaderGeneric(
                  title: medication.guidelines[0].genePhenotype.geneSymbol.name,
                  secondary: Row(
                    children: [
                      Text(medication.guidelines[0].cpicClassification!),
                      Icon(Icons.help_outline),
                    ],
                  ),
                  alignment: MainAxisAlignment.spaceBetween),
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
                    HeaderGeneric(
                      title: context
                          .l10n.medications_details_page_header_recommendation,
                      secondary: Icon(Icons.warning),
                      uppercase: true,
                      alignment: MainAxisAlignment.spaceBetween,
                    ),
                    Text(medication.guidelines[0].recommendation!),
                  ]),
                ),
              ),
              HeaderGeneric(
                  title:
                      context.l10n.medications_details_page_header_further_info,
                  secondary: Icon(Icons.help_outline),
                  uppercase: true),
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
