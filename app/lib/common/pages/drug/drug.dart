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

class DrugPage extends StatelessWidget {
  const DrugPage(
    this.drug, {
    @visibleForTesting this.cubit,
  });

  final Drug drug;
  final DrugCubit? cubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => cubit ?? DrugCubit(drug),
      child: BlocBuilder<DrugCubit, DrugState>(
        builder: (context, state) {
          return state.when(
            initial: () => pageScaffold(title: drug.name, body: []),
            error: () => pageScaffold(
                title: drug.name,
                body: [errorIndicator(context.l10n.err_generic)]),
            loading: () =>
                pageScaffold(title: drug.name, body: [loadingIndicator()]),
            loaded: (drug, isStarred) =>
                pageScaffold(title: drug.name, actions: [
              IconButton(
                onPressed: () => context.read<DrugCubit>().toggleStarred(),
                icon: PharMeTheme.starIcon(isStarred: isStarred),
              ),
              IconButton(
                onPressed: () => sharePdf(drug),
                icon: Icon(
                  Icons.ios_share_rounded,
                  color: PharMeTheme.primaryColor,
                ),
              )
            ], body: [
              _buildDrugsPage(drug, isStarred: isStarred, context: context)
            ]),
          );
        },
      ),
    );
  }

  Widget _buildDrugsPage(
    Drug drug, {
    required bool isStarred,
    required BuildContext context,
  }) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(drug, isStarred: isStarred, context: context),
            SizedBox(height: 20),
            SubHeader(
              context.l10n.drugs_page_header_guideline,
              tooltip: context.l10n.drugs_page_tooltip_guideline,
            ),
            SizedBox(height: 12),
            ...(drug.guidelines.isNotEmpty)
                ? [
                    Disclaimer(),
                    SizedBox(height: 12),
                    ClinicalAnnotationCard(drug)
                  ]
                : [Text(context.l10n.drugs_page_no_guidelines_for_phenotype)]
          ],
        ));
  }

  Widget _buildHeader(Drug drug,
      {required bool isStarred, required BuildContext context}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: PharMeTheme.onSurfaceColor,
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
          child: Text(
            drug.annotations.drugclass,
            style: PharMeTheme.textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.w100,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
          child: Text(drug.annotations.indication),
        )
      ],
    );
  }
}
