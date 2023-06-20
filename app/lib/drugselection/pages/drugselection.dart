import '../../common/models/drug/cached_drugs.dart';
import '../../common/module.dart' hide MetaData;
import '../../common/widgets/full_width_button.dart';
import 'cubit.dart';

class DrugSelectionPage extends HookWidget {
  const DrugSelectionPage({
    Key? key,
    @visibleForTesting this.cubit,
  }) : super(key: key);

  final DrugSelectionPageCubit? cubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => cubit ?? DrugSelectionPageCubit(),
      child: BlocBuilder<DrugSelectionPageCubit, DrugSelectionPageState>(
        builder: (context, state) {
          return Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ListView(
                  children: [
                    _buildHeader(context),
                    ..._buildDrugList(context, state),
                  ],
                ),
              ),
            ),
          );
        }
      )
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Text(
            context.l10n.drug_selection_header,
            style: PharMeTheme.textTheme.headlineLarge),
          SizedBox(height: PharMeTheme.mediumSpace),
          Text(
            context.l10n.drug_selection_description,
            style: PharMeTheme.textTheme.bodyLarge),
          SizedBox(height: PharMeTheme.mediumSpace),
          Text(
            context.l10n.drug_selection_later,
            style: PharMeTheme.textTheme.bodyLarge),
          SizedBox(height: PharMeTheme.mediumSpace),
        ]
      ),
    );
  }

  List<Widget> _buildDrugList(
    BuildContext context,
    DrugSelectionPageState state
  ) {
    var enabled = true;
    state.when(
      stable: () => enabled = true,
      updating: () => enabled = false
    );
    return [
      // ...[...CachedDrugs.instance.drugs!, ...CachedDrugs.instance.drugs!, ...CachedDrugs.instance.drugs!].map(
      ...CachedDrugs.instance.drugs!.map(
        (drug) => CheckboxListTile(
          enabled: enabled,
          value: UserData.instance.activeDrugNames!
            .contains(drug.name),
          onChanged: (value) {
            context
              .read<DrugSelectionPageCubit>()
              .updateDrugActivity(drug, value);  
          },
          title: Text(drug.name.capitalize()),
          subtitle: Text(
            '(${drug.annotations.brandNames.join(", ")})'
          ),
        )
      ).toList(),
      SizedBox(height: PharMeTheme.mediumSpace),
      FullWidthButton(
        context.l10n.general_continue,
        () { context.router.replace(MainRoute()); },
        enabled: enabled,
      ),
    ];
  }
}
