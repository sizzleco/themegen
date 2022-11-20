import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:themegen/src/core/logic/code_producer.dart';
import 'package:themegen/src/core/utils/extension.dart';
import 'package:themegen/src/feature/ext/model/extension.dart' as model;
import 'package:themegen/src/feature/ext/model/extension.dart';
import 'package:themegen/src/feature/theme/theme_producer.dart';

class ExtProducer extends CodeProducer<model.Extension> {
  ExtProducer(super.emitter);

  @override
  Spec spec(model.Extension input) {
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
  Class _extensionClass(String className, Set<TypeExtension> extensions) {
    // there is no matter which extension we take, it could be first, last or even random
    // because each extension has the same properties
    // if it doesn't have such, we will throw an exception
    final type = extensions.first.type;
    final cl = type.element2;
    if (cl == null || cl is! ClassElement) {
      throw Exception('Type $type is not a class');
    }
    final staticFields = cl.fields.where((f) => f.isStatic);
    final staticMethods = cl.methods.where((m) => m.isStatic);
    return Class(
      (builder) => builder
        ..name = className
        ..extend = refer('ThemeExtension<$className>')
        ..fields.addAll(
          _fields(staticFields),
        )
        ..fields.addAll(
          _fieldsFromMethods(staticMethods),
        )
        ..methods.addAll([
          ...extensions.map(
            (typeExtension) => _extensionStaticMethod(
              className,
              typeExtension,
            ),
          ),
          _lerp(
            className,
            staticFields,
            staticMethods,
          ),
          _copyWith(
            className,
            staticFields,
            staticMethods,
          ),
        ])
        ..constructors.addAll(
          [
            Constructor(
              (builder) => builder
                ..optionalParameters.addAll(
                  _params(
                    cl.fields,
                    type,
                    required: true,
                    toThis: true,
                  ),
                )
                ..optionalParameters.addAll(
                  _paramsFromMethods(staticMethods),
                )
                ..initializers.addAll(
                  _initializersFromMethods(staticMethods),
                ),
            ),
            _lerpConstructor(
              staticFields,
              staticMethods,
              type,
              className,
            ),
          ],
        ),
    );
  }

  Iterable<Code> _lerpConstructorInitializers(
    Iterable<FieldElement> fields,
    Iterable<MethodElement> methods,
  ) sync* {
    for (final field in fields) {
      final name = field.name;
      yield Code('$name = ${field.type}.lerp($name, other.$name, t)!');
    }
    for (final method in methods) {
      final name = method.name;
      final params = method.paramsToFillLower();
      yield Code(
        '$name = ${method.returnType}.lerp($name(${params.join(',')}), other._\$$name(${params.join(',')}), t)!',
      );
      yield Code('_\$$name = $name');
      yield* method.paramsToFillLower().toSet().map((e) => Code('_\$$e = $e'));
    }
  }

  Constructor _lerpConstructor(
    Iterable<FieldElement> fields,
    Iterable<MethodElement> methods,
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

  Iterable<Code> _initializersFromMethods(
    Iterable<MethodElement> methods,
  ) sync* {
    yield* methods.map(
      (m) => Code('${m.name} = ${m.name}(${m.paramsToFillLower().join(', ')})'),
    );
    yield* methods.map(
      (m) => Code('_\$${m.name} = ${m.name}'),
    );
    yield* methods.paramsForMethods().map(
          (param) => Code(
            '_\$${param.lowerCaseFirst} = ${param.lowerCaseFirst}',
          ),
        );
  }

  Iterable<Parameter> _paramsFromMethods(
    Iterable<MethodElement> methods, {
    bool required = true,
  }) sync* {
    yield* methods.map(
      (m) {
        final returnType = m.returnType.getDisplayString(withNullability: true);

        return Parameter(
          (builder) => builder
            ..name = m.name
            ..named = true
            ..required = required
            ..type = refer(
              '$returnType Function(${m.paramsToFill().join(', ')})${required ? '' : '?'}',
            ),
        );
      },
    );
    yield* methods.paramsForMethods().map(
          (e) => Parameter(
            (builder) => builder
              ..name = e.lowerCaseFirst
              ..named = true
              ..type = refer(e)
              ..required = true,
          ),
        );
  }

  Iterable<Field> _fieldsFromMethods(
    Iterable<MethodElement> methods,
  ) sync* {
    yield* methods.map(
      (m) {
        if (m.returnType.isDynamic) {
          throw UnsupportedError(
            'Return Type is required for method, '
            'but it was not specified \n$m',
          );
        }
        return Field(
          (builder) => builder
            ..name = m.name
            ..type = refer(
              m.returnType.getDisplayString(
                withNullability: true,
              ),
            )
            ..modifier = FieldModifier.final$,
        );
      },
    );
    yield* methods.map((m) {
      final returnType = m.returnType.getDisplayString(
        withNullability: true,
      );
      return Field(
        (builder) => builder
          ..name = '_\$${m.name}'
          ..type = refer('$returnType Function(${m.paramsToFill().join(', ')})')
          ..modifier = FieldModifier.final$,
      );
    });

    yield* methods.paramsForMethods().map(
          (param) => Field(
            (builder) => builder
              ..name = '_\$' + param.lowerCaseFirst
              ..type = refer(param)
              ..modifier = FieldModifier.final$,
          ),
        );
  }

  /// generates static method like
  ///
  /// {YOUR_NAMESPACE}.${light}() => ...
  Method _extensionStaticMethod(String className, TypeExtension ext) {
    final cl = ext.type.element2;
    final name = ext.name.lowerCaseFirst;
    final type = ext.type;
    if (cl == null || cl is! ClassElement) {
      throw Exception('Type ${ext.type} is not a class');
    }
    // make first letter lowercase
    return Method(
      (builder) => builder
        ..static = true
        ..annotations.add(refer('factory'))
        ..lambda = true
        ..optionalParameters.addAll([
          ..._params(
            cl.fields,
            type,
          ),
          ..._paramsFromMethods(
            cl.methods,
            required: false,
          ),
        ])
        ..body = Code('''
        $className(
          ${cl.fields.map((e) => '${e.displayName}: ${e.displayName} ?? ${cl.displayName}.${e.displayName}').joinParams(',')}
          ${cl.methods.map((e) => '${e.displayName}: ${e.displayName} ?? ${cl.displayName}.${e.displayName}').joinParams(',')}
          ${cl.methods.paramsForMethods().map((e) => '${e.lowerCaseFirst}: ${e.lowerCaseFirst}').joinParams(',')}
          )
        ''')
        ..returns = refer(className)
        ..name = name,
    );
  }

  Iterable<Field> _fields(
    Iterable<FieldElement> fields,
  ) =>
      fields.map(
        (e) => Field(
          (builder) => builder
            ..name = e.name
            ..modifier = FieldModifier.final$
            ..type = refer(e.type.getDisplayString(withNullability: false)),
        ),
      );

  Iterable<Parameter> _params(
    Iterable<FieldElement> fields,
    DartType type, {
    bool named = true,
    bool required = false,
    bool toThis = false,
    bool defaultTo = false,
  }) =>
      fields.map(
        (e) => Parameter(
          (builder) => builder
            ..name = e.name
            ..named = named
            ..required = required
            ..toThis = toThis
            ..defaultTo = defaultTo
                ? Code(
                    type.getDisplayString(withNullability: false) + '.${e.name}',
                  )
                : null
            ..type = toThis
                ? null
                : refer(
                    '${e.type.getDisplayString(withNullability: false)}${required ? '' : '?'}',
                  ),
        ),
      );

  Method _lerp(
    String className,
    Iterable<FieldElement> fields,
    Iterable<MethodElement> methods,
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
              ${methods.map((e) => '${e.name}: _\$${e.name}').joinParams(',')}
              ${methods.paramsForMethods().map((e) => '${e.lowerCaseFirst}: _\$${e.lowerCaseFirst}').joinParams(',')}
              ${fields.map((e) => '${e.name}: ${e.name}').joinParams(',')}
            );
            '''),
      );

  Method _copyWith(
    String className,
    Iterable<FieldElement> fields,
    Iterable<MethodElement> methods,
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
            ${methods.paramsForMethods().map((e) => '${e.lowerCaseFirst}: ${e.lowerCaseFirst} ?? _\$${e.lowerCaseFirst}').join(',')}
          );
        ''')
          ..optionalParameters.addAll([
            for (final field in fields)
              Parameter(
                (builder) => builder
                  ..name = field.name
                  ..named = true
                  ..type = refer(
                    field.type.getDisplayString(withNullability: false) + '?',
                  ),
              ),
            for (final method in methods)
              Parameter(
                (builder) => builder
                  ..name = method.name
                  ..named = true
                  ..type = refer(
                    '${method.returnType} Function(${method.getParamsForMethod().toSet().expand((e) => e.split(' ')).where(ThemeProducer.extensions.containsKey).join(', ')})?',
                  ),
              ),
            ...methods.paramsForMethods().map(
                  (param) => Parameter(
                    (builder) => builder
                      ..name = param.lowerCaseFirst
                      ..named = true
                      ..type = refer('$param?'),
                  ),
                )
          ]),
      );
}
