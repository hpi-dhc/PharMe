import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../common/module.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pages = <Widget>[
    WelcomePage(),
    MedicinePage(),
    SecurityPage(),
  ];
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  bool get isLastPage => _currentPage == _pages.length - 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.1, 0.4, 0.7, 0.9],
            colors: [
              Color(0xFF3594DD),
              Color(0xFF4563DB),
              Color(0xFF5036D5),
              Color(0xFF5B16D0),
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
                  controller: _pageController,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  children: _pages,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildPageIndicator(),
              ),
              _buildNextButton(context),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPageIndicator() {
    final list = <Widget>[];
    for (var i = 0; i < _pages.length; ++i) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
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

  Widget _buildNextButton(BuildContext context) {
    return Expanded(
      child: Align(
        alignment: FractionalOffset.bottomRight,
        child: TextButton(
          onPressed: () {
            if (isLastPage) {
              context.router.pushNamed('auth/login');
            } else {
              _pageController.nextPage(
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

class WelcomePage extends StatelessWidget {
  const WelcomePage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: SvgPicture.asset(
              'assets/images/onboarding_welcome.svg',
              width: 300,
              height: 300,
            ),
          ),
          SizedBox(height: 30),
          Text(
            context.l10n.onboarding_welcome_page_header,
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              height: 1.5,
            ),
          ),
          SizedBox(height: 15),
          Text(
            context.l10n.onboarding_welcome_page_text,
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

class MedicinePage extends StatelessWidget {
  const MedicinePage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: SvgPicture.asset(
              'assets/images/onboarding_medicine.svg',
              width: 300,
              height: 300,
            ),
          ),
          SizedBox(height: 30),
          Text(
            context.l10n.onboarding_medicine_page_header,
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              height: 1.5,
            ),
          ),
          SizedBox(height: 15),
          Text(
            context.l10n.onboarding_medicine_page_text,
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

class SecurityPage extends StatelessWidget {
  const SecurityPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: SvgPicture.asset(
              'assets/images/onboarding_security.svg',
              width: 300,
              height: 300,
            ),
          ),
          SizedBox(height: 30),
          Text(
            context.l10n.onboarding_security_page_header,
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              height: 1.5,
            ),
          ),
          SizedBox(height: 15),
          Text(
            context.l10n.onboarding_security_page_text,
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
