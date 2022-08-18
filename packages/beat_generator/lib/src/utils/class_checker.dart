import 'package:analyzer/dart/element/element.dart';

bool isEnumClass(Element element) {
  return element is ClassElement && element is EnumElement;
}
