// ignore_for_file: avoid_returning_null_for_void

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../l10n.dart';
import '../../models/module.dart';
import '../../theme.dart';
import '../../utilities/pdf_utils.dart';
import '../../widgets/module.dart';
import 'cubit.dart';
import 'widgets/module.dart';

class MedicationPage extends StatelessWidget {
  const MedicationPage(
    this.id,
    this.name, {
    @visibleForTesting this.cubit,
  });

  final int id;
  final String name;
  final MedicationsCubit? cubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => cubit ?? MedicationsCubit(id),
      child: BlocBuilder<MedicationsCubit, MedicationsState>(
        builder: (context, state) {
          return state.when(
            initial: () => pageScaffold(title: name, body: []),
            error: () => pageScaffold(
                title: name, body: [errorIndicator(context.l10n.err_generic)]),
            loading: () =>
                pageScaffold(title: name, body: [loadingIndicator()]),
            loaded: (medication, isStarred) =>
                pageScaffold(title: medication.name, actions: [
              IconButton(
                onPressed: () =>
                    context.read<MedicationsCubit>().toggleStarred(),
                icon: PharMeTheme.starIcon(isStarred: isStarred),
              ),
              IconButton(
                onPressed: () => sharePdf(medication),
                icon: Icon(
                  Icons.ios_share_rounded,
                  color: PharMeTheme.primaryColor,
                ),
              )
            ], body: [
              _buildMedicationsPage(medication,
                  isStarred: isStarred, context: context)
            ]),
          );
        },
      ),
    );
  }

  Widget _buildMedicationsPage(
    MedicationWithGuidelines medication, {
    required bool isStarred,
    required BuildContext context,
  }) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(medication, isStarred: isStarred, context: context),
            SizedBox(height: 20),
            SubHeader(
              context.l10n.medications_page_header_guideline,
              tooltip: context.l10n.medications_page_tooltip_guideline,
            ),
            SizedBox(height: 12),
            ...(medication.guidelines.isNotEmpty)
                ? [
                    Disclaimer(),
                    SizedBox(height: 12),
                    ClinicalAnnotationCard(medication)
                  ]
                : [
                    Text(context
                        .l10n.medications_page_no_guidelines_for_phenotype)
                  ]
          ],
        ));
  }

  Widget _buildHeader(MedicationWithGuidelines medication,
      {required bool isStarred, required BuildContext context}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (medication.drugclass != null)
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: PharMeTheme.onSurfaceColor,
              borderRadius: BorderRadius.all(Radius.circular(6)),
            ),
            child: Text(
              medication.drugclass!,
              style: PharMeTheme.textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.w100,
              ),
            ),
          ),
        if (medication.indication != null)
          Container(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
            child: Text(medication.indication!),
          )
      ],
    );
  }
}
