import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:themegen/src/feature/ext/logic/params.dart';
import 'package:themegen/src/feature/ext/model/elements.dart';

Constructor lerpConstructor(
  Iterable<ExtensionField> fields,
  Iterable<ExtensionMethod> methods,
  DartType type,
  String className,
) =>
    Constructor(
      (builder) => builder
        ..name = '_lerp'
        ..optionalParameters.addAll([
          ...paramsFromFields(
            fields,
            type,
          ),
          ...paramsFromMethods(methods),
          Parameter(
            (builder) => builder
              ..name = 't'
              ..required = true
              ..type = refer('double'),
          ),
          Parameter(
            (builder) => builder
              ..name = 'other'
              ..required = true
              ..type = refer(className),
          ),
        ])
        ..initializers.addAll(
          _lerpConstructorInitializers(
            fields,
            methods,
          ),
        ),
    );

Iterable<Code> _lerpConstructorInitializers(
  Iterable<ExtensionField> fields,
  Iterable<ExtensionMethod> methods,
) sync* {
  for (final field in fields) {
    final name = field.name;
    yield Code('$name = ${field.type}.lerp($name, other.$name, t)!');
  }
  for (final method in methods) {
    final name = method.name;
    final params = method.parameters;
    final onlyNames = params.map((p) => p.name).join(', ');
    yield Code(
      '$name = ${method.returnType}.lerp($name($onlyNames), other._\$$name($onlyNames), t)!',
    );
    yield Code('_\$$name = $name');
    yield* params.toSet().map((param) => Code('${param.name} = ${param.name}'));
  }
}
