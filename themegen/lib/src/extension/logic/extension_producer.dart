import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:collection/collection.dart';
import 'package:themegen/src/core/generator/code_producer.dart';
import 'package:themegen/src/core/utils/extension.dart';
import 'package:themegen/src/extension/model/extension_model.dart';

class ExtensionProducer extends BuilderCodeProducer<Set<ExtensionModel>> {
  ExtensionProducer(super.emitter);

  static final _fields = <String, List<FieldElement>>{};
  static final _methods = <String, List<MethodElement>>{};

  @override
  Spec spec(String className, Set<ExtensionModel> info) {
    final model = info.firstOrNull;
    if (model == null) {
      throw Exception('No model found');
    }
    final group = model.group;
    final fields = model.fields;
    final methods = model.methods;

    if (group != null && _fields[group] == null && _methods[group] == null) {
      if (_fields[group] == null) {
        _fields[group] = fields;
      }
      if (_methods[group] == null) {
        _methods[group] = methods;
      }
      _checkFieldsEquality(_fields[group] ?? <FieldElement>[], fields);
      _checkFieldsEquality(_methods[group] ?? <MethodElement>[], methods);
      return Library(
        (l) => l.body.addAll(
          [
            _genParentClass(
              className,
              fields,
              methods,
              groupName: group,
            ),
            _genClass(
              className,
              fields,
              methods,
              groupName: group,
            ),
          ],
        ),
      );
    }

    return _genClass(
      className,
      fields,
      methods,
      groupName: model.group,
    );
  }

  static Class _genParentClass(
    String className,
    Iterable<FieldElement> fields,
    Iterable<MethodElement> methods, {
    String? groupName,
  }) {
    final name = (groupName ?? className).capitalized;

    return Class(
      (p0) => p0
        ..name = name
        ..fields.addAll(
          _genFields(
            fields: fields,
            methods: methods,
          ),
        )
        ..extend = refer('ThemeExtension<$name>')
        ..methods.addAll(
          _genExtensionMethods(
            fields: fields,
            methods: methods,
            name: name,
          ),
        )
        ..constructors.addAll(
          _genConstructor(
            fields,
            methods,
            className,
            isRequired: true,
          ),
        ),
    );
  }

  static Class _genClass(
    String className,
    Iterable<FieldElement> fields,
    Iterable<MethodElement> methods, {
    String? groupName,
  }) {
    final name = className.replaceAll(r'$', '').replaceAll('_', '');
    return Class(
      (p0) => p0
        ..name = name
        ..extend = groupName == null
            ? refer('ThemeExtension<$name>')
            : refer(groupName.capitalized)
        ..fields.addAll([
          if (groupName == null)
            ..._genFields(
              fields: fields,
              methods: methods,
            ),
        ])
        ..methods.addAll([
          if (groupName == null)
            ..._genExtensionMethods(
              fields: fields,
              methods: methods,
              name: className,
            ),
        ])
        ..constructors.addAll(
          _genConstructor(
            fields,
            methods,
            className,
            isDefault: true,
            toSuper: groupName != null,
          ),
        ),
    );
  }

  static Iterable<Method> _genExtensionMethods({
    required String name,
    required Iterable<FieldElement> fields,
    required Iterable<MethodElement> methods,
  }) sync* {
    yield Method(
      (p0) => p0
        ..name = 'copyWith'
        ..annotations.add(
          refer('override'),
        )
        ..returns = refer(name)
        ..optionalParameters.addAll(
          fields.map(
            (e) => Parameter(
              (p1) => p1
                ..name = e.name
                ..named = true
                ..type = refer(
                  '${e.type.getDisplayString(withNullability: false)}?',
                ),
            ),
          ),
        )
        ..body = Code('''
          return $name(
              ${fields.map((e) => '${e.name}: ${e.name} ?? this.${e.name}').join(', ')}
              );
              '''),
    );
    yield Method(
      (p0) => p0
        ..name = 'lerp'
        ..annotations.add(refer('override'))
        ..requiredParameters.addAll([
          Parameter(
            (p1) => p1
              ..name = 'other'
              ..type = refer('ThemeExtension<$name>?'),
          ),
          Parameter(
            (p1) => p1
              ..name = 't'
              ..type = refer('double'),
          ),
        ])
        ..returns = refer(name)
        ..body = Code(
          '''
              if (other is! $name) {
                return this;
              }
              return $name(
                ${fields.map((e) => '${e.name} : ${lerp(e)}!').join(', ')}
              );
          ''',
        ),
    );
  }

  static Iterable<Constructor> _genConstructor(
    Iterable<FieldElement> fields,
    Iterable<MethodElement> methods,
    String className, {
    bool isDefault = false,
    bool isRequired = false,
    bool toSuper = false,
  }) sync* {
    assert(isDefault && isRequired, 'Only one of the two can be true');
    yield Constructor(
      (p0) => p0
        ..constant = true
        ..optionalParameters.addAll([
          ...fields.map(
            (e) => Parameter(
              (p1) => p1
                ..name = e.name
                ..named = true
                ..defaultTo = isDefault ? Code('$className.${e.name}') : null
                ..required = isRequired
                ..toThis = !toSuper
                ..toSuper = toSuper,
            ),
          ),
          ...methods
              .expand<ParameterElement>((element) => element.parameters)
              .toSet()
              .map(
            (e) {
              return Parameter(
                (p1) => p1
                  ..name = e.name
                  ..required = toSuper
                  ..type = refer(
                    e.type.getDisplayString(withNullability: false),
                  )
                  ..named = true
                  ..toSuper = toSuper,
              );
            },
          ),
        ]),
    );
  }

  static Iterable<Field> _genFields({
    required Iterable<FieldElement> fields,
    required Iterable<MethodElement> methods,
  }) sync* {
    yield* fields.map(
      (e) => Field(
        (f) => f
          ..name = e.displayName
          ..type = refer(
            e.type.getDisplayString(withNullability: false),
          )
          ..modifier = FieldModifier.final$,
      ),
    );
    yield* methods.map(
      (e) => Field(
        (f) => f
          ..name = e.displayName
          ..type = refer(
            e.returnType.getDisplayString(withNullability: false),
          )
          ..modifier = FieldModifier.final$,
      ),
    );
  }

  static void _checkFieldsEquality<T extends Element>(
    Iterable<T> e1,
    Iterable<T> e2,
  ) {
    for (final f in e2) {
      final sameField = e1.firstWhereOrNull(
        (e) => e.name == f.name,
      );
      if (sameField == null) {
        throw Exception('There is no field with the name ${f.name}');
      }
      if (e1.length != e2.length) {
        throw Exception(
          'The number of fields is different. '
          'Expected ${e1.length} but found ${e2.length}',
        );
      }
    }
  }

  static String? lerp(FieldElement el) {
    String? lerp;
    switch (el.type.toString()) {
      case 'Color':
        lerp = 'Color.lerp';
        break;
      case 'double':
        lerp = 'lerpDouble';
        break;
      case 'TextStyle':
        lerp = 'TextStyle.lerp';
        break;
      case 'BorderRadius':
        lerp = 'BorderRadius.lerp';
        break;
      case 'BorderSide':
        lerp = 'BorderSide.lerp';
        break;
      case 'EdgeInsets':
        lerp = 'EdgeInsets.lerp';
        break;
      case 'BoxShadow':
        lerp = 'BoxShadow.lerp';
        break;
      case 'Offset':
        lerp = 'Offset.lerp';
        break;
      case 'Size':
        lerp = 'Size.lerp';
        break;
      case 'Rect':
        lerp = 'Rect.lerp';
        break;
      case 'Border':
        lerp = 'Border.lerp';
        break;
      case 'BoxConstraints':
        lerp = 'BoxConstraints.lerp';
        break;
      case 'Decoration':
        lerp = 'Decoration.lerp';
        break;
    }
    if (lerp == null) return null;

    return '$lerp(${el.name}, other.${el.name}, t)';
  }
}
