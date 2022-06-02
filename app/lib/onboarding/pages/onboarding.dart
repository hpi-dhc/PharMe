import '../../../common/models/metadata.dart';
import '../../../common/module.dart' hide MetaData;

class OnboardingPage extends HookWidget {
  final _pages = [
    OnboardingSubPage(
      imagePath: 'assets/images/onboarding_welcome.svg',
      getHeader: (context) => context.l10n.onboarding_welcome_page_header,
      getText: (context) => context.l10n.onboarding_welcome_page_text,
      color: Color(0xFFFF7E41),
    ),
    OnboardingSubPage(
      imagePath: 'assets/images/onboarding_medicine.svg',
      getHeader: (context) => context.l10n.onboarding_medicine_page_header,
      getText: (context) => context.l10n.onboarding_medicine_page_text,
      color: Color(0xFFCC0700),
    ),
    OnboardingSubPage(
      imagePath: 'assets/images/onboarding_security.svg',
      getHeader: (context) => context.l10n.onboarding_security_page_header,
      getText: (context) => context.l10n.onboarding_security_page_text,
      color: Color(0xFF359600),
    ),
    OnboardingSubPage(
      imagePath: 'assets/images/onboarding_security.svg',
      getHeader: (context) => context.l10n.onboarding_security_page_header,
      getText: (context) => context.l10n.onboarding_security_page_text,
      color: Color(0xFF00B9FA),
    ),
    OnboardingSubPage(
      imagePath: 'assets/images/onboarding_security.svg',
      getHeader: (context) => context.l10n.onboarding_security_page_header,
      getText: (context) => context.l10n.onboarding_security_page_text,
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
        child: Stack(alignment: Alignment.topCenter, children: [
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
        ]),
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
        color: isActive ? Colors.white : PharmeTheme.onSurfaceColor,
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
          if (_isLoggedIn) {
            context.router.pop();
          } else {
            context.router.replace(LoginRouter());
          }
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
            style: PharmeTheme.textTheme.headlineSmall!
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
    required this.imagePath,
    required this.getHeader,
    required this.getText,
    required this.color,
  });

  final String imagePath;
  final String Function(BuildContext) getHeader;
  final String Function(BuildContext) getText;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: SvgPicture.asset(
              imagePath,
              width: 256,
              height: 256,
            ),
          ),
          SizedBox(height: 32),
          Text(
            getHeader(context),
            style: PharmeTheme.textTheme.headlineSmall!.copyWith(
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Text(
            getText(context),
            style: PharmeTheme.textTheme.bodyMedium!.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
