import '../../../common/module.dart';

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
        drawer: FilterMenu(cubit),
      ),
    );
  }
}
