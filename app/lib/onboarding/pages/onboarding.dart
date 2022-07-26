import 'package:url_launcher/url_launcher.dart';

import '../../../common/models/metadata.dart';
import '../../../common/module.dart' hide MetaData;

class OnboardingPage extends HookWidget {
  final _pages = [
    OnboardingSubPage(
      illustrationPath: 'assets/images/onboarding/1.gif',
      getHeader: (context) => context.l10n.onboarding_1_header,
      getText: (context) => context.l10n.onboarding_1_text,
      color: Color(0xFFFF7E41),
    ),
    OnboardingSubPage(
      illustrationPath: 'assets/images/onboarding/2.gif',
      getHeader: (context) => context.l10n.onboarding_2_header,
      getText: (context) => context.l10n.onboarding_2_text,
      color: Color(0xFFCC0700),
    ),
    OnboardingSubPage(
      illustrationPath: 'assets/images/onboarding/3.gif',
      getHeader: (context) => context.l10n.onboarding_3_header,
      getText: (context) => context.l10n.onboarding_3_text,
      color: Color(0xFF359600),
      child: BottomCard(
        icon: Icon(Icons.warning_rounded, size: 32),
        getText: (context) => context.l10n.onboarding_3_disclaimer,
      ),
    ),
    OnboardingSubPage(
      illustrationPath: 'assets/images/onboarding/4.gif',
      getHeader: (context) => context.l10n.onboarding_4_header,
      getText: (context) => context.l10n.onboarding_4_text,
      color: Color(0xFF00B9FA),
      child: BottomCard(
        getText: (context) => context.l10n.onboarding_4_button,
        onClick: () => launchUrl(
          Uri.parse(
            'https://www.cdc.gov/genomics/gtesting/genetic_testing.htm',
          ),
        ),
      ),
    ),
    OnboardingSubPage(
      illustrationPath: 'assets/images/onboarding/5.gif',
      getHeader: (context) => context.l10n.onboarding_5_header,
      getText: (context) => context.l10n.onboarding_5_text,
      color: Color(0xFF0A64BC),
    ),
  ];

  final _isLoggedIn = MetaData.instance.isLoggedIn ?? false;

  @override
  Widget build(BuildContext context) {
    final colors = _pages.map((page) => page.color);
    final tweenSequenceItems = <TweenSequenceItem>[];
    for (var tweenIndex = 0; tweenIndex < colors.length - 1; tweenIndex++) {
      tweenSequenceItems.add(
        TweenSequenceItem(
          weight: 1,
          tween: ColorTween(
            begin: colors.elementAt(tweenIndex),
            end: colors.elementAt(tweenIndex + 1),
          ),
        ),
      );
    }
    final background = TweenSequence(tweenSequenceItems);

    final pageController = usePageController(initialPage: 0);
    final currentPage = useState(0);

    return Scaffold(
      body: AnimatedBuilder(
        animation: pageController,
        builder: (context, child) {
          final color = pageController.hasClients
              ? pageController.page! / (_pages.length - 1)
              : .0;

          return DecoratedBox(
            decoration: BoxDecoration(
              color: background.evaluate(AlwaysStoppedAnimation(color)),
            ),
            child: child,
          );
        },
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned.fill(
              child: PageView(
                controller: pageController,
                onPageChanged: (newPage) => currentPage.value = newPage,
                children: _pages,
              ),
            ),
            Positioned(
              bottom: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildPageIndicator(context, currentPage.value),
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: _buildNextButton(
                context,
                pageController,
                currentPage.value == _pages.length - 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPageIndicator(BuildContext context, int currentPage) {
    final list = <Widget>[];
    for (var i = 0; i < _pages.length; ++i) {
      list.add(_indicator(context, i == currentPage));
    }
    return list;
  }

  Widget _indicator(BuildContext context, bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 8),
      height: 8,
      width: isActive ? 24 : 16,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : PharMeTheme.onSurfaceColor,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  Widget _buildNextButton(
    BuildContext context,
    PageController pageController,
    bool isLastPage,
  ) {
    return TextButton(
      onPressed: () {
        if (isLastPage) {
          _isLoggedIn
              ? context.router.pop()
              : context.router.replace(LoginRouter());
        } else {
          pageController.nextPage(
            duration: Duration(milliseconds: 500),
            curve: Curves.ease,
          );
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isLastPage
                ? context.l10n.onboarding_get_started
                : context.l10n.onboarding_next,
            style: PharMeTheme.textTheme.headlineSmall!
                .copyWith(color: Colors.white),
          ),
          SizedBox(width: 8),
          Icon(
            Icons.arrow_forward,
            color: Colors.white,
            size: 32,
          ),
        ],
      ),
    );
  }
}

class OnboardingSubPage extends StatelessWidget {
  const OnboardingSubPage({
    required this.illustrationPath,
    this.secondImagePath,
    required this.getHeader,
    required this.getText,
    required this.color,
    this.child,
  });

  final String illustrationPath;
  final String? secondImagePath;
  final String Function(BuildContext) getHeader;
  final String Function(BuildContext) getText;
  final Color color;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          Center(
            child: Image.asset(
              illustrationPath,
              width: 320,
              height: 320,
            ),
          ),
          SizedBox(height: 32),
          Text(
            getHeader(context),
            style: PharMeTheme.textTheme.headlineLarge!.copyWith(
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Text(
            getText(context),
            style: PharMeTheme.textTheme.bodyMedium!.copyWith(
              color: Colors.white,
            ),
          ),
          if (child != null) ...[SizedBox(height: 8), child!],
        ],
      ),
    );
  }
}

class BottomCard extends StatelessWidget {
  const BottomCard({this.icon, required this.getText, this.onClick});

  final Icon? icon;
  final String Function(BuildContext) getText;
  final GestureTapCallback? onClick;

  @override
  Widget build(BuildContext context) {
    final widget = Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(children: [
          if (icon != null) ...[icon!, SizedBox(width: 4)],
          Expanded(
            child: Text(
              getText(context),
              style: PharMeTheme.textTheme.bodyMedium,
              textAlign: (icon != null) ? TextAlign.start : TextAlign.center,
            ),
          ),
        ]),
      ),
    );

    if (onClick != null) return InkWell(onTap: onClick, child: widget);

    return widget;
  }
}
