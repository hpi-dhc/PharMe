import '../module.dart';

class PharMeLogoPage extends StatelessWidget {
  const PharMeLogoPage({
    super.key,
    this.child,
  });

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return unscrollablePageScaffold(
      padding: PharMeTheme.largeSpace,
      body: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: SvgPicture.asset(
                'assets/images/logo.svg',
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: child ?? SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}