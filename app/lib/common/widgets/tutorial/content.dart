import '../../module.dart';

class TutorialContent {
  TutorialContent({
    this.title,
    this.content,
    this.assetPath,
  });

  final String Function(BuildContext)? title;
  final TextSpan Function(BuildContext)? content;
  final String? assetPath;
}