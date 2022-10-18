import 'package:analyzer/dart/element/element.dart';

class ExtensionModel {
  const ExtensionModel({
    required this.fields,
    required this.methods,
    required this.group,
  });

  final String? group;
  final List<FieldElement> fields;
  final List<MethodElement> methods;
}
