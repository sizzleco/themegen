import 'package:analyzer/dart/element/element.dart';
import 'package:themegen/src/core/utils/extension.dart';
import 'package:themegen/src/feature/ext/model/elements.dart';

extension Convert on Never {
  static Iterable<ExtensionField> convertAllFields({
    required Iterable<FieldElement> fields,
    required Iterable<ExtensionMethod> methods,
  }) sync* {
    yield* fields.map(
      (field) => ExtensionField(
        name: field.name,
        type: field.type.getDisplayString(withNullability: false),
      ),
    );
    yield* methods.expand<ExtensionParameter>((method) => method.parameters).map(
          (param) => ExtensionField(
            name: param.name,
            type: param.type,
          ),
        );
    yield* methods.map(
      (method) => ExtensionField(
        name: method.name,
        type: method.returnType,
      ),
    );
    yield* methods.map(
      (method) => ExtensionField(
        name: '_\$${method.name}',
        type: method.type,
      ),
    );
  }

  static Iterable<ExtensionField> convertFields({
    required Iterable<FieldElement> fields,
  }) =>
      fields.map(
        (f) => ExtensionField(
          name: f.name,
          type: f.type.getDisplayString(withNullability: false),
        ),
      );

  static Iterable<ExtensionMethod> convertMethods({
    required Iterable<MethodElement> methods,
  }) =>
      methods.map(
        (m) => ExtensionMethod(
          name: m.name,
          returnType: m.returnType.getDisplayString(withNullability: false),
          parameters: m.getParamsForMethod(),
        ),
      );
}
