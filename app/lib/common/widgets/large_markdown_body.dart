import 'package:flutter_markdown/flutter_markdown.dart';

import '../module.dart';

class LargeMarkdownBody extends StatelessWidget {
  const LargeMarkdownBody({
    super.key,
    required this.data,
    this.onTapLink,
  });

  final String data;
  final void Function(String text, String? href, String title)? onTapLink;

  @override
  Widget build(BuildContext context) => MarkdownBody(
    data: data,
    styleSheet: MarkdownStyleSheet.fromTheme(
      ThemeData(
        textTheme: TextTheme(
          bodyMedium: PharMeTheme.textTheme.bodyLarge,
        )
      )
    ),
    onTapLink: onTapLink,
  );
}