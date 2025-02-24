import 'package:flutter_markdown/flutter_markdown.dart';

import '../module.dart';

class LargeMarkdownBody extends StatelessWidget {
  const LargeMarkdownBody({super.key, required this.data});

  final String data;

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
  );
}