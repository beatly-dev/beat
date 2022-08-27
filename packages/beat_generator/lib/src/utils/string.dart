String firstMatchingList(String source) {
  int bracketCount = 0;
  int start = 0;
  for (var i = 0; i < source.length; ++i) {
    final char = source[i];
    if (char == '[') {
      if (bracketCount == 0) {
        start = i;
      }
      bracketCount++;
    } else if (char == ']') {
      bracketCount--;
    }
    if (char == ']' && bracketCount == 0) {
      return source.substring(start, i + 1);
    }
  }
  return '';
}

String toBeginningOfSentenceCase(String str) {
  if (str.isEmpty) return str;
  return '${str[0].toUpperCase()}${str.substring(1)}';
}

String toDartFieldCase(String str) {
  if (str.isEmpty) return str;
  return '${str[0].toLowerCase()}${str.substring(1)}';
}
