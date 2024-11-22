import '../../../common/module.dart' hide MetaData;
import '../../common/models/metadata.dart';

@RoutePage()
class OnboardingPage extends HookWidget {
  const OnboardingPage({ this.isRevisiting = false });

  final bool isRevisiting;

  @override
  Widget build(BuildContext context) {
    final pages = [
      OnboardingSubPage(
        availableHeight:
          OnboardingDimensions.contentHeight(context, isRevisiting),
        illustrationPath: 'assets/images/onboarding/OutlinedLogo.png',
        header: context.l10n.onboarding_1_header,
        text: context.l10n.onboarding_1_text,
        color: PharMeTheme.sinaiCyan,
        child: DisclaimerCard(
          text: context.l10n.onboarding_1_disclaimer_part_1,
          secondLineText: context.l10n.drugs_page_disclaimer_text_part_2,
        ),
      ),
      OnboardingSubPage(
        availableHeight:
          OnboardingDimensions.contentHeight(context, isRevisiting),
        illustrationPath: 'assets/images/onboarding/DrugReaction.png',
        header: context.l10n.onboarding_2_header,
        text: context.l10n.onboarding_2_text,
        color: PharMeTheme.sinaiMagenta,
      ),
      OnboardingSubPage(
        availableHeight:
          OnboardingDimensions.contentHeight(context, isRevisiting),
        illustrationPath: 'assets/images/onboarding/GenomePower.png',
        header: context.l10n.onboarding_3_header,
        text: context.l10n.onboarding_3_text,
        color: PharMeTheme.sinaiPurple,
        child: DisclaimerCard(
          text: context.l10n.onboarding_3_disclaimer,
        ),
      ),
      OnboardingSubPage(
        availableHeight:
          OnboardingDimensions.contentHeight(context, isRevisiting),
        illustrationPath: 'assets/images/onboarding/Tailored.png',
        header: context.l10n.onboarding_4_header,
        text: context.l10n.onboarding_4_already_tested_text,
        color: Colors.grey.shade600,
      ),
      OnboardingSubPage(
        availableHeight:
          OnboardingDimensions.contentHeight(context, isRevisiting),
        illustrationPath: 'assets/images/onboarding/DataProtection.png',
        header: context.l10n.onboarding_5_header,
        text: context.l10n.onboarding_5_text,
        color: PharMeTheme.sinaiCyan,
      ),
    ];
    final colors = pages.map((page) => page.color);
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
              ? pageController.page! / (pages.length - 1)
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
            if (isRevisiting) Positioned(
              top: OnboardingDimensions.getTopPadding(context),
              right: OnboardingDimensions.sidePadding,
              child: IconButton(
                icon: Icon(
                  Icons.close,
                  size: OnboardingDimensions.iconSize,
                  color: Colors.white,
                ),
                onPressed: () => context.router.back(),
              )
            ),
            Positioned.fill(
              top: OnboardingDimensions.getTopSpace(context, isRevisiting),
              bottom: OnboardingDimensions.getBottomSpace(context),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: OnboardingDimensions.sidePadding,
                ),
                child: PageView(
                  controller: pageController,
                  onPageChanged: (newPage) => currentPage.value = newPage,
                  children: pages,
                ),
              ),
            ),
            Positioned(
              bottom: OnboardingDimensions.getBottomSpace(context) -
                OnboardingDimensions.indicatorSize -
                  OnboardingDimensions.indicatorPadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                  _buildPageIndicator(context, pages, currentPage.value),
              ),
            ),
            Positioned(
              bottom: OnboardingDimensions.getBottomPadding(context),
              right: OnboardingDimensions.sidePadding,
              child: _buildNextButton(
                context,
                pageController,
                currentPage.value == pages.length - 1,
              ),
            ),
            Positioned(
              bottom: OnboardingDimensions.getBottomPadding(context),
              left: OnboardingDimensions.sidePadding,
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

  List<Widget> _buildPageIndicator(
    BuildContext context,
    List<OnboardingSubPage> pages,
    int currentPage,
  ) {
    final list = <Widget>[];
    for (var i = 0; i < pages.length; ++i) {
      list.add(_indicator(context, i == currentPage));
    }
    return list;
  }

  Widget _indicator(BuildContext context, bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: OnboardingDimensions.indicatorSize),
      height: OnboardingDimensions.indicatorSize,
      width: isActive
        ? PharMeTheme.mediumToLargeSpace
        : PharMeTheme.mediumSpace,
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
      iconSize: OnboardingDimensions.iconSize,
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
        iconSize: OnboardingDimensions.iconSize,
        onDarkBackground: true,
      );
    } else {
      return SizedBox.shrink();
    }
  }
}

class OnboardingDimensions {
  static const iconSize = 32.0;
  static const sidePadding = PharMeTheme.mediumSpace;
  static const indicatorSize = PharMeTheme.smallSpace;
  static const indicatorPadding = PharMeTheme.largeSpace;

  static double getTopPadding(BuildContext context) {
    return MediaQuery.of(context).padding.top + sidePadding;
  }

  // ignore: avoid_positional_boolean_parameters
  static double getTopSpace(BuildContext context, bool isRevisiting) {
    return isRevisiting
      ? OnboardingDimensions.getTopPadding(context) +
        OnboardingDimensions.iconSize
      : OnboardingDimensions.getTopPadding(context);
  }

  static double getBottomPadding(BuildContext context) {
    return MediaQuery.of(context).padding.bottom + PharMeTheme.mediumSpace;
  }

  static double getBottomSpace(BuildContext context) {
    // Icon button height and indicators
    const bottomWidgetsSize =  iconSize + indicatorSize + indicatorPadding;
    const spaceBetweenBottomWidgets = PharMeTheme.largeSpace;
    return getBottomPadding(context)
      + bottomWidgetsSize
      + spaceBetweenBottomWidgets;
  }

  // ignore: avoid_positional_boolean_parameters
  static double contentHeight(BuildContext context, bool isRevisiting) {
    return MediaQuery.of(context).size.height
      - getTopSpace(context, isRevisiting)
      - getBottomSpace(context);
  }

  static double contentWidth(BuildContext context) {
    return MediaQuery.of(context).size.width - 2 * sidePadding;
  }
}

class OnboardingSubPage extends HookWidget {
  const OnboardingSubPage({
    required this.illustrationPath,
    this.secondImagePath,
    required this.header,
    required this.text,
    required this.color,
    required this.availableHeight,
    this.child,
  });

  final String illustrationPath;
  final String? secondImagePath;
  final String header;
  final String text;
  final double availableHeight;
  final Color color;
  final Widget? child;

  double? _getContentHeight(GlobalKey contentKey) {
    return contentKey.currentContext?.size?.height;
  }

  double? _getMaxScrollOffset(GlobalKey contentKey) {
    final contentHeight = _getContentHeight(contentKey);
    if (contentHeight == null) return null;
    return contentHeight - availableHeight;
  }

  bool? _contentScrollable(GlobalKey contentKey) {
    final contentHeight = _getContentHeight(contentKey);
    if (contentHeight == null) return null;
    return availableHeight < contentHeight;
  }

  bool? _scrolledToEnd(
    GlobalKey contentKey,
    ScrollController scrollController,
  ) {
    final maxScrollOffset = _getMaxScrollOffset(contentKey);
    if (maxScrollOffset == null) return null;
    return scrollController.offset >= maxScrollOffset;
  }

  @override
  Widget build(BuildContext context) {
    const scrollbarThickness = 6.5;
    const iconButtonPadding = 16.0; // to align the scrollbar
    const horizontalPadding = iconButtonPadding + 3 * scrollbarThickness;
    const imageHeight = 175.0;
    final contentKey =  GlobalKey();
    final showScrollIndicatorButton = useState(false);
    final scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final contentScrollable = _contentScrollable(contentKey) ?? false;
      final scrolledToEnd = _scrolledToEnd(contentKey, scrollController) ?? false;
      showScrollIndicatorButton.value = contentScrollable && !scrolledToEnd;
    });

    scrollController.addListener(() {
      final hideButton = _scrolledToEnd(contentKey, scrollController) ?? false;
      showScrollIndicatorButton.value = !hideButton;
    });
 
    return Stack(
      alignment: Alignment.center,
      children: [
        RawScrollbar(
          controller: scrollController, // needed to always show scrollbar
          thumbVisibility: true,
          shape: StadiumBorder(),
          padding: EdgeInsets.only(
            top: PharMeTheme.mediumToLargeSpace,
            right: iconButtonPadding,
          ),
          thumbColor: Colors.white,
          thickness: scrollbarThickness,
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
              ),
              child: Column(
                key: contentKey,
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
                        height: imageHeight,
                      ),
                    ),
                  ),
                  SizedBox(height: PharMeTheme.mediumToLargeSpace),
                  Column(children: [
                    AutoSizeText(
                      header,
                      style: PharMeTheme.textTheme.headlineLarge!.copyWith(
                        color: Colors.white,
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(height: PharMeTheme.mediumToLargeSpace),
                    Text(
                      text,
                      style: PharMeTheme.textTheme.bodyLarge!.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    if (child != null) ...[
                      SizedBox(height: PharMeTheme.mediumSpace),
                      child!,
                    ],
                  ]),
                  // Empty widget for spaceBetween in this column to work properly
                  Container(),
                ],
              ),
            ),
          ),
        ),
        if (showScrollIndicatorButton.value) Positioned(
          bottom: 0,
          child: IconButton(
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              side: BorderSide(color: color, width: 3),
            ),
            icon: Icon(
              Icons.arrow_downward,
              size: OnboardingDimensions.iconSize * 0.85,
              color: color,
            ),
            onPressed: () async {
              await scrollController.animateTo(
                _getMaxScrollOffset(contentKey)!,
                duration: Duration(milliseconds: 500),
                curve: Curves.linearToEaseOut,
              );
              showScrollIndicatorButton.value = false;
            },
          )
        ),
      ],
    );
  }
}

class DisclaimerCard extends StatelessWidget {
  const DisclaimerCard({
    this.icon,
    required this.text,
    this.secondLineText,
    this.onClick,
  });

  final Icon? icon;
  final String text;
  final String? secondLineText;
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
            icon ??  Icon(Icons.warning_rounded, size: 32),
            SizedBox(width: PharMeTheme.smallSpace),
            Expanded(
              child: Column(
                children: [
                  getTextWidget(text),
                  if (secondLineText != null) ...[
                    SizedBox(height: PharMeTheme.smallSpace),
                    getTextWidget(secondLineText!),
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
    textAlign: TextAlign.start,
  );
}
