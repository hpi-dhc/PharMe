import '../../../common/module.dart' hide MetaData;
import '../../common/models/metadata.dart';

@RoutePage()
class OnboardingPage extends HookWidget {
  OnboardingPage({ this.isRevisiting = false });

  final bool isRevisiting;
  
  final _pages = [
    OnboardingSubPage(
      illustrationPath: 'assets/images/onboarding/OutlinedLogo.png',
      getHeader: (context) => context.l10n.onboarding_1_header,
      getText: (context) => context.l10n.onboarding_1_text,
      color: PharMeTheme.sinaiCyan,
      child: disclaimerCard(
        getText: (context) => context.l10n.onboarding_1_disclaimer_part_1,
        getSecondLineText: (context) =>
          context.l10n.drugs_page_disclaimer_text_part_2,
      ),
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
      child: disclaimerCard(
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
            if (isRevisiting) Positioned(
              top: MediaQuery.of(context).padding.top +
                PharMeTheme.mediumToLargeSpace,
              right: PharMeTheme.mediumToLargeSpace,
              child: IconButton(
                icon: Icon(Icons.close, size: 32, color: Colors.white,),
                onPressed: () => context.router.back(),
              )
            ),
            Positioned(
              bottom: 96,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildPageIndicator(context, currentPage.value),
              ),
            ),
            Positioned(
              bottom: PharMeTheme.mediumToLargeSpace,
              right: PharMeTheme.mediumToLargeSpace,
              child: _buildNextButton(
                context,
                pageController,
                currentPage.value == _pages.length - 1,
              ),
            ),
            Positioned(
              bottom: PharMeTheme.mediumToLargeSpace,
              left: PharMeTheme.mediumToLargeSpace,
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
    return DirectionButton(
      key: Key('nextButton'),
      direction: ButtonDirection.forward,
      text: isLastPage
        ? isRevisiting
          ? context.l10n.action_back_to_app
          : context.l10n.onboarding_get_started
        : context.l10n.onboarding_next,
      onPressed: () async {
        if (isLastPage) {
          if (isRevisiting) {
            context.router.back();
          } else {
            MetaData.instance.onboardingDone = true;
            await MetaData.save();
            // ignore: use_build_context_synchronously
            await context.router.push(
              DrugSelectionRoute(concludesOnboarding: true)
            );
          }
        } else {
          await pageController.nextPage(
            duration: Duration(milliseconds: 500),
            curve: Curves.ease,
          );
        }
      },
      onDarkBackground: true,
      emphasize: isLastPage,
    );
  }

  Widget _buildPrevButton(
    BuildContext context,
    PageController pageController,
    bool isFirstPage,
  ) {
    if (!isFirstPage) {
      return DirectionButton(
        key: Key('prevButton'),
        direction: ButtonDirection.backward,
        onPressed: () {
          pageController.previousPage(
              duration: Duration(milliseconds: 500),
              curve: Curves.ease,
            );
        },
        text: context.l10n.onboarding_prev,
        onDarkBackground: true,
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

BottomCard disclaimerCard({
  required String Function(BuildContext) getText,
  String Function(BuildContext)? getSecondLineText,
}) => BottomCard(
  getText: getText,
  icon: Icon(Icons.warning_rounded, size: 32),
  getSecondLineText: getSecondLineText,
);

class BottomCard extends StatelessWidget {
  const BottomCard({
    this.icon,
    required this.getText,
    this.getSecondLineText,
    this.onClick,
  });

  final Icon? icon;
  final String Function(BuildContext) getText;
  final String Function(BuildContext)? getSecondLineText;
  final GestureTapCallback? onClick;

  @override
  Widget build(BuildContext context) {
    final widget = Card(
      color: PharMeTheme.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(PharMeTheme.smallSpace),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              icon!,
              SizedBox(width: PharMeTheme.smallSpace),
            ],
            Expanded(
              child: Column(
                children: [
                  getTextWidget(getText(context)),
                  if (getSecondLineText != null) ...[
                    SizedBox(height: PharMeTheme.smallSpace),
                    getTextWidget(getSecondLineText!(context)),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (onClick != null) return InkWell(onTap: onClick, child: widget);

    return widget;
  }

  Widget getTextWidget(String text) => Text(
    text,
    style: PharMeTheme.textTheme.bodyMedium,
    textAlign: (icon != null) ? TextAlign.start : TextAlign.center,
  );
}
