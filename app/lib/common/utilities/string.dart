extension Ilike on String {
  bool ilike(String matcher) {
    return toLowerCase().contains(matcher.toLowerCase());
  }
}
