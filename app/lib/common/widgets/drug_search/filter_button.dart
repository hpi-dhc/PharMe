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
