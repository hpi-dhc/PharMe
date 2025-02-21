import '../../module.dart';

class DisclaimerRow extends StatelessWidget {
  const DisclaimerRow({super.key, required this.icon, required this.text});

  final Widget icon;
  final Widget text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            right: PharMeTheme.smallSpace,
          ),
          child: icon,
        ),
        Expanded(child: text),
      ],
    );
  }
}