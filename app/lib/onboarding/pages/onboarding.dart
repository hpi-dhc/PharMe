import 'package:auto_route/auto_route.dart';
import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../common/module.dart';
import '../../../common/routing/router.dart';

class OnboardingPage extends HookWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageController = usePageController(initialPage: 0);
    final currentPage = useState(0);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              context.theme.colorScheme.primary,
              context.theme.colorScheme.primaryContainer,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 600,
                child: PageView(
                  controller: pageController,
                  onPageChanged: (newPage) => currentPage.value = newPage,
                  children: _pages,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildPageIndicator(currentPage.value),
              ),
              _buildNextButton(
                context,
                pageController,
                currentPage.value == _pages.length - 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPageIndicator(int currentPage) {
    final list = <Widget>[];
    for (var i = 0; i < _pages.length; ++i) {
      list.add(i == currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 8),
      height: 8,
      width: isActive ? 24 : 16,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Color(0xFF7B51D3),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  Widget _buildNextButton(
    BuildContext context,
    PageController pageController,
    bool isLastPage,
  ) {
    return Expanded(
      child: Align(
        alignment: FractionalOffset.bottomRight,
        child: TextButton(
          onPressed: () {
            if (isLastPage) {
              context.router.replace(const LoginRouter());
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
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                ),
              ),
              SizedBox(width: 10),
              Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final _pages = <Widget>[
  OnboardingSubPage(
    imagePath: 'assets/images/onboarding_welcome.svg',
    getHeader: (context) => {context.l10n.onboarding_welcome_page_header},
    getText: (context) => {context.l10n.onboarding_welcome_page_text},
  ),
  OnboardingSubPage(
    imagePath: 'assets/images/onboarding_medicine.svg',
    getHeader: (context) => {context.l10n.onboarding_medicine_page_header},
    getText: (context) => {context.l10n.onboarding_medicine_page_text},
  ),
  OnboardingSubPage(
    imagePath: 'assets/images/onboarding_security.svg',
    getHeader: (context) => {context.l10n.onboarding_security_page_header},
    getText: (context) => {context.l10n.onboarding_security_page_text},
  ),
];

class OnboardingSubPage extends StatelessWidget {
  const OnboardingSubPage({
    Key? key,
    required this.imagePath,
    required this.getHeader,
    required this.getText,
  }) : super(key: key);

  final String imagePath;
  final Set<String> Function(BuildContext) getHeader;
  final Set<String> Function(BuildContext) getText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: SvgPicture.asset(
              imagePath,
              width: 300,
              height: 300,
            ),
          ),
          SizedBox(height: 30),
          Text(
            getHeader(context).single,
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              height: 1.5,
            ),
          ),
          SizedBox(height: 15),
          Text(
            getText(context).single,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              height: 1.2,
            ),
          )
        ],
      ),
    );
  }
}
