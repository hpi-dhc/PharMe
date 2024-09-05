import 'package:provider/provider.dart';

import '../../common/models/metadata.dart';
import '../../common/module.dart' hide MetaData;
import '../cubit.dart';

@RoutePage()
class DrugSelectionPage extends HookWidget {
  const DrugSelectionPage({
    super.key,
    this.concludesOnboarding = true,
    @visibleForTesting this.cubit,
  });

  final DrugSelectionCubit? cubit;
  final bool concludesOnboarding;

  @override
  Widget build(BuildContext context) {
    return Consumer<ActiveDrugs>(
      builder: (context, activeDrugs, child) => BlocProvider(
        create: (context) => cubit ?? DrugSelectionCubit(activeDrugs),
        child: BlocBuilder<DrugSelectionCubit, DrugSelectionState>(
          builder: (context, state) {
            final initialDrugSelectionInitiated =
              MetaData.instance.initialDrugSelectionInitiated ?? false;
            if (concludesOnboarding && !initialDrugSelectionInitiated) {
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                await showDrugSelectionIntro(context);
              });
            }
            return unscrollablePageScaffold(
              title: context.l10n.drug_selection_header,
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: PharMeTheme.smallSpace),
                    child: PageDescription.fromText(
                      concludesOnboarding
                        ? context.l10n.drug_selection_onboarding_description
                        : context.l10n.drug_selection_settings_description,
                    ),
                  ),
                  Expanded(child: _buildDrugList(context, state)),
                  if (concludesOnboarding) _buildButton(context, state),
                ],
              ),
            );
          }
        ),
      ),
    );
  }

  bool _isEditable(DrugSelectionState state) {
    return state.when(
      stable: () => true,
      updating: () => false
    );
  }

  Widget _buildButton(BuildContext context, DrugSelectionState state) {
    return Padding(
      padding: EdgeInsets.all(PharMeTheme.mediumSpace),
      child: FullWidthButton(
        context.l10n.action_continue,
        () async {
          MetaData.instance.initialDrugSelectionDone = true;
          await MetaData.save();
          // ignore: use_build_context_synchronously
          await overwriteRoutes(context, nextPage: MainRoute());
        },
        enabled: _isEditable(state),
      )
    );
  }

  Widget _buildDrugList(BuildContext context, DrugSelectionState state) {
    if (CachedDrugs.instance.drugs!.isEmpty) {
      return Column(
        children: [
          Text(
            context.l10n.drug_selection_no_drugs_loaded,
            style: PharMeTheme.textTheme.bodyLarge!.copyWith(
              fontStyle: FontStyle.italic
            ),
          ),
        ],
      );
    }
    return withFilterData(
      cubit: DrugListCubit(),
      builder: (context, builderCubit, builderState, activeDrugs) => DrugSearch(
        key: Key('drug-selection'),
        showFilter: false,
        cubit: builderCubit,
        state: builderState,
        activeDrugs: activeDrugs,
        keepPosition: true,
        useDrugClass: false,
        buildDrugItems: buildDrugSelectionList,
        drugItemsBuildParams: DrugItemsBuildParams(
          isEditable: _isEditable(state),
          setActivity: context.read<DrugSelectionCubit>().updateDrugActivity,
        ),
        showDrugInteractionIndicator: !concludesOnboarding,
      ),
    );
  }
}
