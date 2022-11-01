import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:themegen/src/core/logic/code_producer.dart';
import 'package:themegen/src/core/utils/extension.dart';
import 'package:themegen/src/feature/ext/model/data_extension.dart';

class ExtProducer extends CodeProducer<DataExtension> {
  ExtProducer(super.emitter);

  @override
  Spec spec(DataExtension input) {
    final dataClass = _extensionClass(
      input.dataClassName,
      input.extensions,
      input.index,
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
  Class _extensionClass(String className, Set<DartType> types, int index) {
    final type = types.first;
    final cl = type.element2;
    if (cl == null || cl is! ClassElement) {
      throw Exception('Type $type is not a class');
    }
    final staticFields = cl.fields.whereType<FieldElement>().where(
          (f) => f.isStatic,
        );
    return Class(
      (builder) => builder
        ..name = className
        ..extend = refer('ThemeExtension<$className>')
        ..fields.addAll(
          _fields(cl.fields),
        )
        ..methods.addAll([
          ...types.map(
            (e) => _extensionStaticMethod(
              className,
              e,
              index,
            ),
          ),
          _lerp(className, staticFields),
          _copyWith(className, staticFields),
        ])
        ..constructors.add(
          Constructor(
            (builder) => builder
              ..optionalParameters.addAll(
                _params(
                  cl.fields,
                  type,
                  required: true,
                  toThis: true,
                ),
              ),
          ),
        ),
    );
  }

  /// generates static method like
  ///
  /// {YOUR_NAMESPACE}.${light}() => ...
  Method _extensionStaticMethod(String className, DartType type, int index) {
    final display = type.getDisplayString(withNullability: false);
    final name = display.splitPascalCase().sublist(index);
    final cl = type.element2;
    if (cl == null || cl is! ClassElement) {
      throw Exception('Type $type is not a class');
    }
    name[0] = name[0].toLowerCase();
    return Method(
      (builder) => builder
        ..static = true
        ..annotations.add(refer('factory'))
        ..lambda = true
        ..body = Code('''
        $className(${cl.fields.map((e) => '${e.displayName}: ${cl.displayName}.${e.displayName}').join(',')})
        ''')
        ..returns = refer(className)
        ..name = name.join(),
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
                    type.getDisplayString(withNullability: false) +
                        '.${e.name}',
                  )
                : null
            ..type = toThis
                ? null
                : refer(
                    e.type.getDisplayString(withNullability: false),
                  ),
        ),
      );

  Method _lerp(String className, Iterable<FieldElement> fields) => Method(
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
            return $className(
              ${fields.map((e) => '${e.name}: ${e.type}.lerp(${e.name}, other.${e.name}, t)!').join(',\n')}
            );
            '''),
      );

  Method _copyWith(String className, Iterable<FieldElement> fields) => Method(
        (builder) => builder
          ..name = 'copyWith'
          ..returns = refer(className)
          ..annotations.add(refer('override'))
          ..body = Code('''
          return $className(
            ${fields.map((f) => '${f.name}: ${f.name} ?? this.${f.name}').join(',')}
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
          ]),
      );
}
