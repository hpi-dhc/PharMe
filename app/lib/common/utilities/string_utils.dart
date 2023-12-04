import '../module.dart';

extension Ilike on String {
  bool ilike(String matcher) {
    return toLowerCase().contains(matcher.toLowerCase());
  }
}

String enumerationWithAnd(List<String> items, BuildContext context) {
  final itemsCopy = [ ...items ];
  if (itemsCopy.isEmpty) return '';
  if (itemsCopy.length == 1) {
    return itemsCopy.first;
  }
  final lastItem = itemsCopy.removeLast();
  return '${itemsCopy.join(', ')} ${context.l10n.general_and} $lastItem';
}

String formatAsSentence(String text, {String ending = '.'}) {
  var sentenceFormattedString = text.capitalize();
  if (!sentenceFormattedString.endsWith(ending)) {
    sentenceFormattedString = '$sentenceFormattedString$ending';
  }
  return sentenceFormattedString;
}
