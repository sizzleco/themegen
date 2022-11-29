import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:themegen/src/core/utils/extensions.dart';
import 'package:themegen/src/feature/ext/logic/convert.dart';
import 'package:themegen/src/feature/ext/model/elements.dart';
import 'package:themegen/src/feature/ext/model/extension_model.dart';

/// generates static method like
///
/// {YOUR_NAMESPACE}.${light}() => ...
Method extensionMethod(
  String className,
  ExtensionType ext,
) {
  final cl = ext.type.element2;
  final name = ext.name.lowerCaseFirst;
  if (cl == null || cl is! ClassElement) {
    throw Exception('Type ${ext.type} is not a class');
  }
  final fields = Convert.convertFields(fields: cl.fields.where((f) => f.isStatic));
  final methods = Convert.convertMethods(methods: cl.methods.where((m) => m.isStatic));
  // make first letter lowercase
  return Method(
    (builder) => builder
      ..static = true
      ..lambda = true
      ..annotations.add(refer('factory'))
      ..optionalParameters.addAll([
        ..._fields(fields, ext),
        ..._methodsWithParams(methods),
      ])
      ..body = Code('''
        $className(
          ${fields.map((field) => '${field.name}: ${field.name} ?? ${cl.displayName}.${field.name}').joinParams(',')}
          ${methods.map((e) => '${e.name}: ${e.name} ?? ${cl.displayName}.${e.name}').joinParams(',')}
          ${methods.expand((e) => e.parameters).map((e) => '${e.name}: ${e.name}').joinParams(',')}
          )
        ''')
      ..returns = refer(className)
      ..name = name,
  );
}

Iterable<Parameter> _fields(
  Iterable<ExtensionField> fields,
  ExtensionType extensionType,
) =>
    fields.map(
      (field) => Parameter(
        (builder) => builder
          ..name = field.name
          ..named = true
          ..type = refer(
            '${field.type}?',
          ),
      ),
    );

Iterable<Parameter> _methodsWithParams(
  Iterable<ExtensionMethod> methods,
) sync* {
  yield* methods.map(
    (m) {
      final returnType = m.returnType;
      final params = m.parameters;
      final types = params.map((e) => e.type).join(', ');
      return Parameter(
        (builder) => builder
          ..name = m.name
          ..named = true
          ..type = refer(
            '$returnType Function($types)?',
          ),
      );
    },
  );
  yield* methods.expand((element) => element.parameters).map(
        (e) => Parameter(
          (builder) => builder
            ..name = e.name
            ..named = true
            ..type = refer(e.type)
            ..required = true,
        ),
      );
}
