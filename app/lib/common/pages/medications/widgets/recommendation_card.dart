import 'package:flutter/material.dart';

import '../../../l10n.dart';
import '../../../models/module.dart';
import '../../../theme.dart';
import 'sub_header.dart';

class RecommendationCard extends StatelessWidget {
  const RecommendationCard(
    this.medication, {
    required this.isOkGuideline,
    required this.context,
  });

  final MedicationWithGuidelines medication;
  final bool isOkGuideline;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: medication.guidelines[0].warningLevel == WarningLevel.danger.name
          ? Color(0xFFFFAFAF)
          : medication.guidelines[0].warningLevel == WarningLevel.ok.name
              ? Color(0xFF00FF00)
              : Color(0xFFFFEBCC),
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
                  medication.guidelines[0].warningLevel ==
                          WarningLevel.danger.name
                      ? Icons.dangerous_rounded
                      : medication.guidelines[0].warningLevel ==
                              WarningLevel.ok.name
                          ? Icons.check_circle_rounded
                          : Icons.warning_rounded,
                  size: 32),
            ],
          ),
          SizedBox(height: 4),
          Text(
            medication.guidelines[0].recommendation ??
                medication.guidelines[0].cpicRecommendation!,
            style: PharmeTheme.textTheme.bodyLarge,
          ),
        ]),
      ),
    );
  }
}
