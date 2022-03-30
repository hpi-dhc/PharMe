import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension PharmeL10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

typedef L10nStringGetter = String Function(AppLocalizations l10n);
