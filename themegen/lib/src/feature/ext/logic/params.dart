import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:themegen/src/feature/ext/model/elements.dart';

Iterable<Parameter> paramsFromFields(
  Iterable<ExtensionField> fields,
  DartType type, {
  bool named = true,
  bool required = false,
  bool toThis = false,
  bool defaultTo = false,
}) =>
    fields.map(
      (field) => Parameter(
        (builder) => builder
          ..name = field.name
          ..named = named
          ..required = required
          ..toThis = toThis
          ..defaultTo = defaultTo
              ? Code(
                  type.getDisplayString(withNullability: false) + '.${field.name}',
                )
              : null
          ..type = toThis
              ? null
              : refer(
                  '${field.type}${required ? '' : '?'}',
                ),
      ),
    );

Iterable<Parameter> paramsFromMethods(
  Iterable<ExtensionMethod> methods, {
  bool required = true,
}) sync* {
  yield* methods.map(
    (m) {
      final returnType = m.returnType;
      final params = m.parameters;
      final types = params.map((e) => e.type).join(', ');
      return Parameter(
        (builder) => builder
          ..name = m.name
          ..named = true
          ..required = required
          ..type = refer(
            '$returnType Function($types)${required ? '' : '?'}',
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
