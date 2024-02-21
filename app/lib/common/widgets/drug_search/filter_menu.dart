import '../../module.dart';

class FilterButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.filter_list),
      color: PharMeTheme.iconColor,
      onPressed: Scaffold.of(context).openDrawer,
    );
  }
}

class FilterMenuItem {
  FilterMenuItem({
    required bool initialValue,
    required this.updateSearch,
    required this.build,
  }) : _value = initialValue;

  bool _value;
  // ignore: avoid_positional_boolean_parameters
  final void Function(bool newValue) updateSearch;
  final Widget Function(BuildContext context, {
    required bool value,
    required Function statefulOnChange,
  }) build;

  set value(newValue) => _value = newValue;
  bool get value => _value;
}

class FilterMenu extends HookWidget {
  const FilterMenu(this.cubit);

  final DrugListCubit cubit;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: _menuItems.map(
          (item) => PopupMenuItem(child: StatefulBuilder(
            builder: (context, setState) {
              return item.build(
                context,
                value: item.value,
                statefulOnChange: ([_]) {
                  final newValue = !item.value;
                  setState(() => item.value = newValue);
                  item.updateSearch(newValue);
                },
              );
            }),
          ),
        ).toList(),
      ),
    );
  }

  List<FilterMenuItem>  get _menuItems => [
    FilterMenuItem(
      initialValue: cubit.filter?.showInactive ?? false,
      updateSearch: (newValue) => cubit.search(showInactive: newValue),
      build: (context, { required value, required statefulOnChange }) =>
        DropdownButton<bool>(
          value: value,
          items: [
            DropdownMenuItem<bool>(
              value: true,
              child: Text('${context.l10n.search_page_filter_all_drugs} '),
            ),
            DropdownMenuItem<bool>(
              value: false,
              child: Text('${context.l10n.search_page_filter_only_active_drugs} '),
            ),
          ],
          onChanged: (newValue) => statefulOnChange(newValue),
        ),
    ),
    ...WarningLevel.values
      .filter((warningLevel) => warningLevel != WarningLevel.none)
      .map((warningLevel) => FilterMenuItem(
        initialValue: cubit.filter?.showWarningLevel[warningLevel] ?? false,
        updateSearch: (newValue) => cubit.search(
          showWarningLevel: { warningLevel: newValue },
        ),
        build: (context, { required value, required statefulOnChange }) =>
          ActionChip(
            onPressed: () => statefulOnChange(!value),
            avatar: Icon(
              value ? warningLevel.icon : warningLevel.outlinedIcon,
              color: value ? PharMeTheme.onSurfaceText : warningLevel.textColor,
            ),
            label: Text('', style: TextStyle(color: PharMeTheme.onSurfaceText)),
            visualDensity: VisualDensity.compact,
            color: MaterialStatePropertyAll(value ? warningLevel.color : Colors.transparent),
          ),
      )),
  ];
}
