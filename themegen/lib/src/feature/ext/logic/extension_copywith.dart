import 'package:code_builder/code_builder.dart';
import 'package:themegen/src/feature/ext/model/elements.dart';

Method extensionCopywith(
  String className,
  Iterable<ExtensionField> fields,
  Iterable<ExtensionMethod> methods,
) =>
    Method(
      (builder) => builder
        ..name = 'copyWith'
        ..returns = refer(className)
        ..annotations.add(refer('override'))
        ..body = Code('''
          return $className(
            ${fields.map<String>((f) => '${f.name}: ${f.name} ?? this.${f.name}').join(',')}
            ${methods.map((m) => '${m.name}: ${m.name} ?? _\$${m.name}').join(',')},
            ${methods.expand((m) => m.parameters).map((p) => '${p.name}: ${p.name} ?? this.${p.name}').join(',')}
          );
        ''')
        ..optionalParameters.addAll([
          for (final field in fields)
            Parameter(
              (builder) => builder
                ..name = field.name
                ..named = true
                ..type = refer(
                  '${field.type}?',
                ),
            ),
          for (final method in methods)
            Parameter(
              (builder) {
                final params = method.parameters.map((method) => method.type).join(', ');
                builder
                  ..name = method.name
                  ..named = true
                  ..type = refer(
                    '${method.returnType} Function($params)?',
                  );
              },
            ),
          ...methods.expand((method) => method.parameters).map(
                (param) => Parameter(
                  (builder) => builder
                    ..name = param.name
                    ..named = true
                    ..type = refer('${param.type}?'),
                ),
              )
        ]),
    );
