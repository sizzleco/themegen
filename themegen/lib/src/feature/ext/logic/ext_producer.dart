import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:themegen/src/core/logic/code_producer.dart';
import 'package:themegen/src/core/utils/extension.dart';
import 'package:themegen/src/feature/ext/logic/convert.dart';
import 'package:themegen/src/feature/ext/logic/extension.dart';
import 'package:themegen/src/feature/ext/model/elements.dart';
import 'package:themegen/src/feature/ext/model/extension.dart';

class ExtProducer extends CodeProducer<ParentExtension> {
  ExtProducer(super.emitter);

  @override
  Spec spec(ParentExtension input) {
    final dataClass = _extensionClass(
      input.name,
      input.types,
    );
    return Library(
      (builder) => builder.body
        ..addAll([
          dataClass,
        ]),
    );
  }

  /// generates extension class that extends ThemeExtension
  /// to fulfil the contract
  Class _extensionClass(String className, Set<ExtensionType> extensions) {
    // there is no matter which extension we take, it could be first, last or even random
    // because each extension has the same properties
    // if it doesn't have such, we will throw an exception
    final type = extensions.first.type;
    final cl = type.element2;
    if (cl == null || cl is! ClassElement) {
      throw Exception('Type $type is not a class');
    }
    // all static [FieldElement]s for the class
    final staticFields = cl.fields.where((f) => f.isStatic);
    // all static [MethodElement]s for the class
    final staticMethods = cl.methods.where((m) => m.isStatic);
    // all fields that are static + fields extracted from [MethodElement] params
    final $onlyMethods = Convert.convertMethods(methods: staticMethods);
    final $onlyFields = Convert.convertFields(fields: staticFields);
    final $allFields = Convert.convertAllFields(
      fields: staticFields,
      methods: $onlyMethods,
    );
    return Class(
      (builder) => builder
        ..name = className
        ..extend = refer('ThemeExtension<$className>')
        ..fields.addAll(
          _generateFields($allFields),
        )
        ..methods.addAll([
          ...extensions.map(
            (typeExtension) => extensionMethod(
              className,
              typeExtension,
            ),
          ),
          _lerp(
            className,
            $onlyFields,
            $onlyMethods,
          ),
          _copyWith(
            className,
            $onlyFields,
            $onlyMethods,
          ),
        ])
        ..constructors.addAll(
          [
            Constructor(
              (builder) => builder
                ..optionalParameters.addAll(
                  _params(
                    $onlyFields,
                    type,
                    required: true,
                    toThis: true,
                  ),
                )
                ..optionalParameters.addAll(
                  _paramsFromMethods($onlyMethods),
                )
                ..initializers.addAll(
                  _initializersFromMethods($onlyMethods),
                ),
            ),
            _lerpConstructor(
              $onlyFields,
              $onlyMethods,
              type,
              className,
            ),
          ],
        ),
    );
  }

  Constructor _lerpConstructor(
    Iterable<ExtensionField> fields,
    Iterable<ExtensionMethod> methods,
    DartType type,
    String className,
  ) =>
      Constructor(
        (builder) => builder
          ..name = '_lerp'
          ..optionalParameters.addAll([
            ..._params(
              fields,
              type,
              required: true,
            ),
            ..._paramsFromMethods(methods),
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

  Iterable<Code> _initializersFromMethods(
    Iterable<ExtensionMethod> methods,
  ) sync* {
    yield* methods.map(
      (m) {
        final params = m.parameters.map((p) => p.name).join(',');
        return Code('${m.name} = ${m.name}($params)');
      },
    );
    yield* methods.map(
      (m) => Code('_\$${m.name} = ${m.name}'),
    );
    final params = methods.expand<ExtensionParameter>((m) => m.parameters);
    yield* params.toSet().map(
          (p) => Code('${p.name} = ${p.name}'),
        );
  }

  Iterable<Parameter> _paramsFromMethods(
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

  Iterable<Field> _generateFields(
    Iterable<ExtensionField> fields,
  ) =>
      fields.map(
        (field) => Field(
          (builder) => builder
            ..modifier = FieldModifier.final$
            ..name = field.name
            ..type = refer(field.type),
        ),
      );

  Iterable<Parameter> _params(
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

  Method _lerp(
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

  Method _copyWith(
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
}
