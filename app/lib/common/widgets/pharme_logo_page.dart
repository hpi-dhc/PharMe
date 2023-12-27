import '../module.dart';

class PharMeLogoPage extends StatelessWidget {
  const PharMeLogoPage({
    super.key,
    this.child,
    this.greyscale = false,
  });

  final Widget? child;
  final bool greyscale;

  @override
  Widget build(BuildContext context) {
    return unscrollablePageScaffold(
      padding: PharMeTheme.largeSpace,
      body: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: greyscale
                ? ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      PharMeTheme.backgroundColor,
                      BlendMode.softLight,
                    ),
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        PharMeTheme.backgroundColor,
                        BlendMode.saturation,
                      ),
                      child: _buildLogo(context),
                    ),
                  )
                : _buildLogo(context),
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

  Widget _buildLogo(BuildContext context) {
    return SvgPicture.asset('assets/images/logo.svg');
  }
}