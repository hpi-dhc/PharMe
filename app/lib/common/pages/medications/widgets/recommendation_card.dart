import 'package:flutter/material.dart';

import '../../../l10n.dart';
import '../../../models/module.dart';
import '../../../theme.dart';
import 'sub_header.dart';

class RecommendationCard extends StatelessWidget {
  const RecommendationCard(
    this.medication, {
    required this.context,
  });

  final MedicationWithGuidelines medication;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: Key('recommendationCard'),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: medication.guidelines[0].warningLevel?.color ?? Color(0xFFFFEBCC),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SubHeader(
                context.l10n.medications_page_header_recommendation,
              ),
              Icon(
                medication.guidelines[0].warningLevel?.icon ??
                    Icons.warning_rounded,
                size: 32,
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            medication.guidelines[0].recommendation ??
                medication.guidelines[0].cpicRecommendation!,
            style: PharMeTheme.textTheme.bodyLarge,
          ),
        ]),
      ),
    );
  }
}
