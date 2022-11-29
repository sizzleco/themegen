import 'package:code_builder/code_builder.dart';
import 'package:themegen/src/core/utils/extensions.dart';
import 'package:themegen/src/feature/ext/model/elements.dart';

Method lerp(
  String className,
  Iterable<ExtensionField> fields,
  Iterable<ExtensionMethod> methods,
) =>
    Method(
      (builder) => builder
        ..name = 'lerp'
        ..annotations.add(refer('override'))
        ..returns = refer(className)
        ..requiredParameters.addAll([
          Parameter(
            (builder) => builder
              ..name = 'other'
              ..type = refer('ThemeExtension<$className>?'),
          ),
          Parameter(
            (builder) => builder
              ..name = 't'
              ..type = refer('double'),
          ),
        ])
        ..body = Code('''
            if (other is! $className) {
              return this;
            }
            return $className._lerp(
              other: other,
              t: t,
              ${fields.map((e) => '${e.name}: ${e.name}').joinParams(',')}
              ${methods.map((e) => '${e.name}: _\$${e.name}').joinParams(',')}
              ${methods.expand((e) => e.parameters).map((e) => '${e.name}: ${e.name}').joinParams(',')}
            );
            '''),
    );
