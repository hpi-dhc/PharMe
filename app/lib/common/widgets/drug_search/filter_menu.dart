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
  const FilterMenu(this.cubit, this.state, this.activeDrugs, {
    required this.useDrugClass
  });

  final DrugListCubit cubit;
  final DrugListState state;
  final ActiveDrugs activeDrugs;
  final bool useDrugClass;

  @override
  Widget build(BuildContext context) {
    return _buildFilters(context) ?? SizedBox.shrink();
  }

  Widget? _buildFilters(BuildContext context) {
    return state.whenOrNull(loaded: (allDrugs, filter) =>
      SafeArea(
        child: Column(
          children: _geMenuItems(context, allDrugs, filter, activeDrugs),
        ),
      )
    );
  }

  List<Widget> _geMenuItems(
    BuildContext context,
    List<Drug> drugs,
    FilterState filter,
    ActiveDrugs activeDrugs,
  ) {
    String formatItemFilterNumber(FilterState itemFilter) =>
      '(${
        itemFilter.filter(drugs, activeDrugs, useDrugClass: useDrugClass).length
      })';
    String drugStatusNumber({ required bool showInactive}) =>
      formatItemFilterNumber(FilterState.from(
        FilterState.initial(),
        showInactive: showInactive,
      ));
    String warningLevelNumber(WarningLevel warningLevel) {
      final currentWarningLevelFilter = FilterState.from(filter);
      currentWarningLevelFilter.showWarningLevel.forEach(
        (currentWarningLevel, currentValue) =>
          currentWarningLevelFilter.showWarningLevel[currentWarningLevel] =
            currentWarningLevel == warningLevel
      );
      return formatItemFilterNumber(currentWarningLevelFilter);
    }
    Widget buildDrugStatusItem() {
      final value = filter.showInactive;
      return DropdownButton<bool>(
        value: value,
        items: [
          DropdownMenuItem<bool>(
            value: true,
            child: Text(
              '${context.l10n.search_page_filter_all_drugs} '
              '${drugStatusNumber(showInactive: true)}'
            ),
          ),
          DropdownMenuItem<bool>(
            value: false,
            child: Text(
              '${context.l10n.search_page_filter_only_active_drugs} '
              '${drugStatusNumber(showInactive: false)}'
            ),
          ),
        ],
        onChanged: (newValue) => newValue != value
          ? cubit.search(showInactive: newValue)
          : null,
      );
    }
    Widget buildWarningLevelItem(WarningLevel warningLevel) {
      final value = filter.showWarningLevel[warningLevel]!;
      return ActionChip(
        onPressed: () => cubit.search(
          showWarningLevel: { warningLevel: !value },
        ),
        avatar: Icon(
          value ? warningLevel.icon : warningLevel.outlinedIcon,
          color: value ? PharMeTheme.onSurfaceText : warningLevel.textColor,
        ),
        label: Text(warningLevelNumber(warningLevel),
        style: TextStyle(color: PharMeTheme.onSurfaceText)),
        visualDensity: VisualDensity.compact,
        color: MaterialStatePropertyAll(value
          ? warningLevel.color
          : Colors.transparent
        ),
      );
    }
    return [
      buildDrugStatusItem(),
      ...WarningLevel.values
        .filter((warningLevel) => warningLevel != WarningLevel.none)
        .map(buildWarningLevelItem),
    ];
  }
}
