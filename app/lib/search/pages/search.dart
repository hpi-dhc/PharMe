import 'package:flutter/cupertino.dart';
import 'package:scio/scio.dart';

import '../../../common/module.dart';
import 'cubit.dart';

class SearchPage extends HookWidget {
  const SearchPage({
    Key? key,
    @visibleForTesting this.cubit,
  }) : super(key: key);

  final SearchCubit? cubit;

  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();

    return BlocProvider(
      create: (context) => cubit ?? SearchCubit(),
      child: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          return Column(
            children: [
              Row(children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: CupertinoSearchTextField(
                      controller: searchController,
                      onChanged: (value) {
                        context.read<SearchCubit>().loadMedications(value);
                      },
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => context.read<SearchCubit>().toggleFilter(),
                  icon: PharMeTheme.starIcon(
                      isStarred: state.when(
                          initial: (filter) => filter,
                          loading: (filter) => filter,
                          loaded: (_, filter) => filter,
                          error: (filter) => filter)),
                ),
              ]),
              state.when(
                initial: (_) => Container(),
                error: (_) => Text(context.l10n.err_generic),
                loaded: (medications, _) => _buildMedicationsList(medications),
                loading: (_) => Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Flexible _buildMedicationsList(List<MedicationWithGuidelines> medications) {
    return Flexible(
      child: ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 14),
        itemCount: medications.length,
        itemBuilder: (context, index) {
          final med = medications[index];
          return MedicationCard(
              onTap: () {
                ComprehensionHelper.instance.attach(
                  context.router.push(MedicationRoute(id: med.id)),
                  context: context,
                  surveyId: 4,
                  introText: context.l10n.comprehension_intro_text,
                  surveyButtonText:
                      context.l10n.comprehension_survey_button_text,
                  supabaseConfig: supabaseConfig,
                );
              },
              medication: med);
        },
        separatorBuilder: (_, __) => SizedBox(height: 8),
      ),
    );
  }
}

class MedicationCard extends StatelessWidget {
  const MedicationCard({
    required this.onTap,
    required this.medication,
  });

  final VoidCallback onTap;
  final MedicationWithGuidelines medication;

  @override
  Widget build(BuildContext context) {
    final warningLevel = medication.highestWarningLevel();

    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 5,
        color: warningLevel?.color ?? Colors.grey[200],
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      if (warningLevel != null) ...[
                        Icon(warningLevel.icon),
                        SizedBox(width: 12)
                      ],
                      Text(
                        medication.name,
                        style: PharMeTheme.textTheme.titleMedium,
                      ),
                    ]),
                    if (medication.indication.isNotNullOrBlank) ...[
                      SizedBox(height: 12),
                      Text(
                        medication.indication!,
                        style: PharMeTheme.textTheme.titleSmall,
                      ),
                    ]
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
