String createClass(String className, String body, {bool isAbstract = false}) {
  return '''
${isAbstract ? 'abstract' : ''} class $className {
  $body
}
''';
}
