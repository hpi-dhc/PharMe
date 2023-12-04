import '../../../common/module.dart' hide MetaData;

class OnboardingPage extends HookWidget {
  OnboardingPage({ required this.nextPage });

  final PageRouteInfo<dynamic> nextPage;
  
  final _pages = [
    OnboardingSubPage(
      illustrationPath: 'assets/images/onboarding/OutlinedLogo.png',
      getHeader: (context) => context.l10n.onboarding_1_header,
      getText: (context) => context.l10n.onboarding_1_text,
      color: PharMeTheme.sinaiCyan,
    ),
    OnboardingSubPage(
      illustrationPath: 'assets/images/onboarding/DrugReaction.png',
      getHeader: (context) => context.l10n.onboarding_2_header,
      getText: (context) => context.l10n.onboarding_2_text,
      color: PharMeTheme.sinaiMagenta,
    ),
    OnboardingSubPage(
      illustrationPath: 'assets/images/onboarding/GenomePower.png',
      getHeader: (context) => context.l10n.onboarding_3_header,
      getText: (context) => context.l10n.onboarding_3_text,
      color: PharMeTheme.sinaiPurple,
      child: BottomCard(
        icon: Icon(Icons.warning_rounded, size: 32),
        getText: (context) => context.l10n.onboarding_3_disclaimer,
      ),
    ),
    OnboardingSubPage(
      illustrationPath: 'assets/images/onboarding/Tailored.png',
      getHeader: (context) => context.l10n.onboarding_4_header,
      getText: (context) => context.l10n.onboarding_4_already_tested_text,
      color: Colors.grey.shade600,
    ),
    OnboardingSubPage(
      illustrationPath: 'assets/images/onboarding/DataProtection.png',
      getHeader: (context) => context.l10n.onboarding_5_header,
      getText: (context) => context.l10n.onboarding_5_text,
      color: PharMeTheme.sinaiCyan,
    ),
  ];

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
              bottom: 96,
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
            Positioned(
              bottom: 16,
              left: 16,
              child: _buildPrevButton(
                context,
                pageController,
                currentPage.value == 0,
              ),
            )
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
      key: Key('nextButton'),
      onPressed: () {
        if (isLastPage) {
            // Replace whole stack, see https://stackoverflow.com/a/73784156
            context.router.pushAndPopUntil(
              nextPage,
              predicate: (_) => false
            );
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
            Icons.arrow_forward_rounded,
            color: Colors.white,
            size: 32,
          ),
        ],
      ),
    );
  }

  Widget _buildPrevButton(
    BuildContext context,
    PageController pageController,
    bool isFirstPage,
  ) {
    if (!isFirstPage) {
      return TextButton(
        key: Key('prevButton'),
        onPressed: () {
          pageController.previousPage(
              duration: Duration(milliseconds: 500),
              curve: Curves.ease,
            );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 32,
            ),
            SizedBox(width: 8),
            Text(
              context.l10n.onboarding_prev,
              style: PharMeTheme.textTheme.headlineSmall!
                  .copyWith(color: Colors.white),
            ),
          ],
        ),
      );
    } else {
      return SizedBox.shrink();
    }
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
      padding: const EdgeInsets.fromLTRB(32, 16, 32, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: PharMeTheme.mediumSpace),
          Center(
            child: FractionallySizedBox(
              alignment: Alignment.topCenter,
              widthFactor: 0.75,
              child: Image.asset(
                illustrationPath,
                height: 200,
              ),
            ),
          ),
          SizedBox(height: PharMeTheme.mediumSpace),
          Column(children: [
            AutoSizeText(
              getHeader(context),
              style: PharMeTheme.textTheme.headlineLarge!.copyWith(
                color: Colors.white,
              ),
              maxLines: 2,
            ),
            SizedBox(height: PharMeTheme.mediumSpace),
            Text(
              getText(context),
              style: PharMeTheme.textTheme.bodyLarge!.copyWith(
                color: Colors.white,
              ),
            ),
            if (child != null) ...[SizedBox(height: PharMeTheme.mediumSpace), child!],
          ]),
          // Empty widget for spaceBetween in this column to work properly
          Container(),
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
