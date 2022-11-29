import 'package:meta/meta.dart';

@immutable
class ExtensionField {
  const ExtensionField({
    required this.name,
    required this.type,
  });

  final String name;
  final String type;

  @override
  String toString() => 'Field(name: $name)';
}

@immutable
class ExtensionMethod {
  const ExtensionMethod({
    required this.name,
    required this.returnType,
    required this.parameters,
  });

  final String name;
  final List<ExtensionParameter> parameters;
  final String returnType;

  @override
  String toString() => 'Method(name: $name, returnType: $returnType, parameters: $parameters)';

  String get type {
    final params = parameters
        .map((param) => '${param.decorators.join(' ')} ${param.type} ${param.name}')
        .join(', ');
    return '$returnType Function($params)';
  }
}

@immutable
class ExtensionParameter {
  const ExtensionParameter({
    required this.name,
    required this.type,
    this.decorators = const [],
  });

  final String name;
  final String type;
  final List<String> decorators;

  @override
  String toString() => 'Parameter(name: $name, type: $type)';
}
