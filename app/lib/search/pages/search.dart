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
    const useDrugClass = true;
    return withFilterData(
      cubit: cubit,
      builder: (context, cubit, state, activeDrugs) => PopScope(
        canPop: false,
        child: unscrollablePageScaffold(
          title: context.l10n.tab_drugs,
          body: DrugSearch(
            key: Key('drug-search'),
            showFilter: true,
            buildDrugItems: buildDrugCards,
            cubit: cubit,
            state: state,
            activeDrugs: activeDrugs,
            showDrugInteractionIndicator: false,
            useDrugClass: useDrugClass,
          ),
          drawer: FilterMenu(
            cubit,
            state,
            activeDrugs,
            useDrugClass: useDrugClass,
          ),
          automaticallyImplyLeading: false, // do not show leading "menu" icon
        ),
      ),
    );
  }
}
