import '../../module.dart';

const privacyRoutes = CustomRoute(
  path: 'privacy',
  name: 'PrivacyRouter',
  page: PrivacyPage,
  transitionsBuilder: TransitionsBuilders.zoomIn,
);

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PharMeLogoPage();
  }
}