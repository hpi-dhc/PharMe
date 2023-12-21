import '../module.dart';

class FilterMenuItem {
  FilterMenuItem({
    required this.title,
    required this.updateSearch,
    required bool isChecked,
  }) : _isChecked = isChecked;

  final String title;
  final void Function({ required bool isChecked }) updateSearch;
  bool _isChecked;

  set checked(newValue) => _isChecked = newValue;
  bool get checked => _isChecked;
}

class FilterMenu extends HookWidget {
  const FilterMenu({
    super.key,
    this.headerItem,
    required this.items,
    required this.iconData,
  });

  final Widget? headerItem;
  final List<FilterMenuItem> items;
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<FilterMenuItem>(
      icon: Icon(iconData),
      color: PharMeTheme.onSurfaceColor,
      elevation: 0,
      itemBuilder: (context) => items.map(
        (item) => PopupMenuItem<FilterMenuItem>(
          child: StatefulBuilder(builder: (context, setState) {
            void toggleCheckbox([_]) {
              final newValue = !item.checked;
              setState(() => item.checked = newValue);
              item.updateSearch(isChecked: newValue);
            }
            return ListTile(
              title: Text(item.title),
              leading: Checkbox.adaptive(
                value: item.checked,
                onChanged: toggleCheckbox,
              ),
              onTap: toggleCheckbox,
            );
          }),
        )
      ).toList(),
    );
  }
}