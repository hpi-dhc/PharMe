import '../../module.dart';

class TutorialPage {
  TutorialPage ({
    this.title,
    this.content,
    this.assetPath,
  });

  final String Function(BuildContext)? title;
  final Widget Function(BuildContext)? content;
  final String? assetPath;
}