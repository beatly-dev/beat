bool isNullContextType(String contextType) {
  return contextType == 'Null' || contextType == 'void';
}

bool isNotNullContextType(String contextType) {
  return !isNullContextType(contextType);
}

bool isNullableContextType(String contextType) {
  return isNullContextType(contextType) ||
      contextType.contains('?') ||
      contextType == 'dynamic';
}
