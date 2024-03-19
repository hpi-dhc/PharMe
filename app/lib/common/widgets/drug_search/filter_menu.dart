import '../../module.dart';

class FilterMenuItem {
  FilterMenuItem({
    required bool initialValue,
    required this.updateSearch,
    required this.build,
  }) : _value = initialValue;

  bool _value;
  // ignore: avoid_positional_boolean_parameters
  final void Function(bool newValue) updateSearch;
  final Widget Function(
    BuildContext context, {
    required bool value,
    required Function statefulOnChange,
  }) build;

  set value(newValue) => _value = newValue;
  bool get value => _value;
}

class FilterMenu extends HookWidget {
  const FilterMenu(this.cubit, this.state, this.activeDrugs,
      {required this.useDrugClass});

  final DrugListCubit cubit;
  final DrugListState state;
  final ActiveDrugs activeDrugs;
  final bool useDrugClass;

  @override
  Widget build(BuildContext context) {
    return _buildFilters(context) ?? SizedBox.shrink();
  }

  Widget? _buildFilters(BuildContext context) {
    return state.whenOrNull(
        loaded: (allDrugs, filter) => SafeArea(
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(
                  color: PharMeTheme.surfaceColor,
                  width: PharMeTheme.smallSpace,
                ),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(PharMeTheme.smallSpace),
                )),
            child: Container(
              color: PharMeTheme.surfaceColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: PharMeTheme.mediumSpace,
                      right: PharMeTheme.mediumSpace,
                      bottom: PharMeTheme.mediumSpace,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        IconButton(
                          key: Key('close-filter-drawer-button'),
                          onPressed: Scaffold.of(context).closeDrawer,
                          icon: Icon(Icons.arrow_back_ios_rounded),
                          color: PharMeTheme.iconColor,
                          visualDensity: VisualDensity.compact,
                        ),
                        SizedBox(width: PharMeTheme.smallSpace * 0.5),
                        Text(
                          context.l10n.search_page_filter_heading,
                          style: PharMeTheme.textTheme.headlineMedium,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: PharMeTheme.mediumSpace,
                      right: PharMeTheme.mediumSpace,
                      bottom: PharMeTheme.mediumSpace,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: PharMeTheme.mediumSpace),
                        SubheaderDivider(
                          text: context.l10n.search_page_filter_subheading_usage,
                          useLine: false,
                          padding: 0,
                        ),
                        _getDrugStatusFilter(context, allDrugs, filter),
                        SizedBox(height: PharMeTheme.mediumSpace),
                        SubheaderDivider(
                          text: context.l10n.search_page_filter_subheading_level,
                          useLine: false,
                          padding: 0,
                        ),
                        SizedBox(height: PharMeTheme.smallSpace),
                        ..._getWarningLevelFilters(context, allDrugs, filter),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  int _getFilteredNumber({
    required FilterState itemFilter,
    required List<Drug> drugs,
  }) {
    return itemFilter
      .filter(drugs, activeDrugs, useDrugClass: useDrugClass)
      .length;
  }

  bool _filterIsEnabled({
    required FilterState itemFilter,
    required List<Drug> drugs,
  }) => _getFilteredNumber(itemFilter: itemFilter, drugs: drugs) > 0;

  Widget _getFilterText(
    String text, {
    required FilterState itemFilter,
    required List<Drug> drugs,
    bool enabled = true,
  }) {
    final numberTextColor = darkenColor(PharMeTheme.onSurfaceText, -0.2);
    final disabledTextColor = darkenColor(numberTextColor, -0.2);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          text,
          style: PharMeTheme.textTheme.bodyMedium!.copyWith(
            color: enabled
              ? PharMeTheme.textTheme.bodyMedium!.color
              : disabledTextColor,
          ),
        ),
        Text(
          ' (${_getFilteredNumber(itemFilter: itemFilter, drugs: drugs)})',
          style: PharMeTheme.textTheme.labelMedium!.copyWith(
            color: enabled ? numberTextColor : disabledTextColor,
          ),
        ),
      ],
    );
  }

  Widget _getDrugStatusFilter(
    BuildContext context,
    List<Drug> drugs,
    FilterState filter,
  ) {
    final value = filter.showInactive;
    FilterState drugStatusFilterState({ required bool showInactive }) {
      return FilterState.from(
        FilterState.initial(),
        showInactive: showInactive,
      );
    }
    DropdownMenuItem<bool> buildDrugStatusDropdownItem({
      required bool showInactive,
    }) {
      final itemFilter = drugStatusFilterState(showInactive: showInactive);
      final text = showInactive
        ? context.l10n.search_page_filter_all_drugs
        : context.l10n.search_page_filter_only_active_drugs;
      final enabled = _filterIsEnabled(itemFilter: itemFilter, drugs: drugs);
      return DropdownMenuItem<bool>(
        key: Key('drug-status-filter-${showInactive.toString()}'),
        value: showInactive,
        enabled: enabled,
        child: _getFilterText(
          text,
          itemFilter: itemFilter,
          drugs: drugs,
          enabled: enabled,
        ),
      );
    }

    return DropdownButton<bool>(
      key: Key('drug-status-filter-dropdown'),
      value: value,
      items: [
        buildDrugStatusDropdownItem(showInactive: true),
        buildDrugStatusDropdownItem(showInactive: false),
      ],
      onChanged: (newValue) =>
          newValue != value ? cubit.search(showInactive: newValue) : null,
    );
  }

  List<Widget> _getWarningLevelFilters(
    BuildContext context,
    List<Drug> drugs,
    FilterState filter,
  ) {
    FilterState warningLevelFilter(WarningLevel warningLevel) {
      final currentFilter = FilterState.from(filter);
      currentFilter.showWarningLevel.forEach(
          (currentWarningLevel, currentValue) =>
              currentFilter.showWarningLevel[currentWarningLevel] =
                  currentWarningLevel == warningLevel);
      return currentFilter;
    }
    Widget buildWarningLevelItem(WarningLevel warningLevel) {
      final value = filter.showWarningLevel[warningLevel]!;
      final itemFilter = warningLevelFilter(warningLevel);
      final enabled = _filterIsEnabled(itemFilter: itemFilter, drugs: drugs);
      return ActionChip(
        onPressed: enabled
          ? () => cubit.search(
            showWarningLevel: {warningLevel: !value},
          )
          : null,
        avatar: Icon(
          value && enabled ? warningLevel.icon : warningLevel.outlinedIcon,
          color: PharMeTheme.onSurfaceText,
        ),
        label: _getFilterText(
          warningLevel.getLabel(context),
          itemFilter: itemFilter,
          drugs: drugs,
        ),
        visualDensity: VisualDensity.compact,
        color: MaterialStatePropertyAll(
          value && enabled ? warningLevel.color : Colors.transparent,
        ),
        side: BorderSide(
          color: value && enabled
            ? warningLevel.color
            : PharMeTheme.onSurfaceColor,
        ),
      );
    }
    return WarningLevel.values.map(buildWarningLevelItem).toList();
  }
}
