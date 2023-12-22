import '../../../common/module.dart';
import '../../common/widgets/drug_list/drug_items/drug_cards.dart';
import '../../common/widgets/drug_search.dart';

@RoutePage()
class SearchPage extends HookWidget {
  SearchPage({
    super.key,
    @visibleForTesting DrugListCubit? cubit,
  })  : cubit = cubit ?? DrugListCubit();

  final DrugListCubit cubit;

  @override
  Widget build(BuildContext context) {
    useOnAppLifecycleStateChange((previous, current) async {
      if (current == AppLifecycleState.resumed) {
        await cubit.loadDrugs(useCache: false);
      }
    });
    return PopScope(
      canPop: false,
      child: unscrollablePageScaffold(
        title: context.l10n.tab_drugs,
        body: DrugSearch(
          showFilter: true,
          buildDrugItems: buildDrugCards,
          cubit: cubit,
          showDrugInteractionIndicator: true,
        ),
      ),
    );
  }
}
