// ignore_for_file: avoid_returning_null_for_void

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../l10n.dart';
import '../../models/module.dart';
import '../../theme.dart';
import '../../utilities/module.dart';
import '../../utilities/pdf_utils.dart';
import '../../widgets/module.dart';
import 'cubit.dart';
import 'widgets/module.dart';

class MedicationPage extends StatelessWidget {
  const MedicationPage(this.id);

  final int id;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MedicationsCubit(id),
      child: BlocBuilder<MedicationsCubit, MedicationsState>(
        builder: (context, state) {
          return RoundedCard(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
            child: state.when(
              initial: Container.new,
              error: () => Text(context.l10n.err_generic),
              loading: () => Center(child: CircularProgressIndicator()),
              loaded: (medication) => _buildMedicationsPage(
                filterUserGuidelines(medication),
                context: context,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMedicationsPage(
    MedicationWithGuidelines medication, {
    required BuildContext context,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(medication),
        SizedBox(height: 20),
        Disclaimer(),
        SizedBox(height: 20),
        SubHeader(
          context.l10n.medications_page_header_guideline,
          tooltip: context.l10n.medications_page_tooltip_guideline,
        ),
        SizedBox(height: 12),
        if (medication.guidelines.isNotEmpty)
          ClinicalAnnotationCard(medication)
        else
          Text(context.l10n.medications_page_no_guidelines_for_phenotype),
      ],
    );
  }

  Widget _buildHeader(
    MedicationWithGuidelines medication,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(medication.name, style: PharmeTheme.textTheme.displaySmall),
            IconButton(
              onPressed: () => sharePdf(medication),
              icon: Icon(
                Icons.ios_share,
                size: 32,
                color: PharmeTheme.primaryColor,
              ),
            ),
          ],
        ),
        if (medication.drugclass != null)
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: PharmeTheme.onSurfaceColor,
              borderRadius: BorderRadius.all(Radius.circular(6)),
            ),
            child: Text(
              medication.drugclass!,
              style: PharmeTheme.textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.w100,
              ),
            ),
          ),
      ],
    );
  }
}
