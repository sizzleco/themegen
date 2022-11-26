import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:themegen/src/core/logic/code_producer.dart';
import 'package:themegen/src/feature/ext/logic/convert.dart';
import 'package:themegen/src/feature/ext/logic/extension_copywith.dart';
import 'package:themegen/src/feature/ext/logic/extension_lerp.dart';
import 'package:themegen/src/feature/ext/logic/extension_method.dart';
import 'package:themegen/src/feature/ext/logic/lerp_constructor.dart';
import 'package:themegen/src/feature/ext/logic/params.dart';
import 'package:themegen/src/feature/ext/model/elements.dart';
import 'package:themegen/src/feature/ext/model/extension_model.dart';

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
          /// generate all extension methods, i.e. light, dark, etc.
          ...extensions.map(
            (typeExtension) => extensionMethod(
              className,
              typeExtension,
            ),
          ),
          lerp(
            className,
            $onlyFields,
            $onlyMethods,
          ),
          extensionCopywith(
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
                  paramsFromFields(
                    $onlyFields,
                    type,
                    required: true,
                    toThis: true,
                  ),
                )
                ..optionalParameters.addAll(
                  paramsFromMethods($onlyMethods),
                )
                ..initializers.addAll(
                  _initializersFromMethods($onlyMethods),
                ),
            ),
            lerpConstructor(
              $onlyFields,
              $onlyMethods,
              type,
              className,
            ),
          ],
        ),
    );
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
}
