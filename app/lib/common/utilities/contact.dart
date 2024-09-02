import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../module.dart';

// Note that sending emails will not work on the iPhone Simulator since it does
// not have any email application installed.

String contactEmailAddress = 'ehivepgx@mssm.edu';

class CopyText extends HookWidget {
  const CopyText({
    required this.text,
    this.label,
    this.bold = false,
    this.scrollable = false,
  });

  final String text;
  final String? label;
  final bool bold;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final copySuccess = useState<bool>(false);
    var textStyle = TextStyle();
    if (bold) textStyle = textStyle.copyWith(fontWeight: FontWeight.bold);
    if (scrollable) {
      textStyle = textStyle.copyWith(
        backgroundColor: PharMeTheme.onSurfaceColor,
      );
    }
    final textComponent = Text(
      text,
      style: textStyle,
      maxLines: 1,
    );
    final icon = copySuccess.value
        ? Icons.check
        : Icons.copy;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotNullOrBlank) ...[
          Text(
            label!,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(width: PharMeTheme.smallSpace),
        ],
        Expanded(
          child: scrollable
            ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: textComponent,
            )
            : textComponent,
        ),
        SizedBox(width: PharMeTheme.smallSpace),
        GestureDetector(
          child: Icon(
            icon,
            color: PharMeTheme.iconColor,
            size: PharMeTheme.mediumSpace,
          ),
          onTap: () async => {
            copySuccess.value = true,
            await Clipboard.setData(ClipboardData(text: text)),
            Future.delayed(Duration(seconds: 1), () => copySuccess.value = false),
          },
        ),
      ],
    );
  }

}

// Workaround according to https://pub.dev/packages/url_launcher#encoding-urls
String? _encodeQueryParameters(Map<String, String> params) {
return params.entries
    .map((entry) =>
      '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value)}'
    ).join('&');
}
Future<void> sendEmail(BuildContext context, {
  String subject = '',
  String body = '',
}) async {
  await showAdaptiveDialog(
    context: context,
    builder: (context) => DialogWrapper(
      title: context.l10n.more_page_contact_us,
      content: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: PharMeTheme.smallSpace),
            Text(context.l10n.contact_text),
            SizedBox(height: PharMeTheme.smallSpace),
            CopyText(text: contactEmailAddress, bold: true),
            if (subject.isNotBlank || body.isNotBlank) ...[
              SizedBox(height: PharMeTheme.smallSpace),
              Text(context.l10n.contact_context_text),
              if (subject.isNotBlank) ...[
                SizedBox(height: PharMeTheme.smallSpace),
                CopyText(
                  text: subject,
                  label: context.l10n.contact_subject,
                  scrollable: true,
                ),
              ],
              if (body.isNotBlank) ...[
                SizedBox(height: PharMeTheme.smallSpace),
                CopyText(
                  text: body,
                  label: context.l10n.contact_body,
                  scrollable: true,
                ),
              ],
            ],
          ],
        ),
      ),
      actions: [
        DialogAction(
          text: context.l10n.action_cancel,
          onPressed: () => Navigator.pop(context),
        ),
        DialogAction(
          text: context.l10n.contact_open_mail,
          isDefault: true,
          onPressed: () async => launchUrl(
            Uri(
              scheme: 'mailto',
              path: contactEmailAddress,
              query: _encodeQueryParameters({
                'subject': subject,
                'body': body,
              }),
            ),
          ),
        ),
      ],
    ),
  );
}