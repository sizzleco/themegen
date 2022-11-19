import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:themegen/src/feature/ext/model/extension.dart';

@immutable
class InputModel {
  final DartType type;
  final List<String> pascalCase;

  const InputModel(this.type, this.pascalCase);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InputModel &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          const DeepCollectionEquality().equals(pascalCase, other.pascalCase);

  @override
  int get hashCode => Object.hashAll([runtimeType, type, ...pascalCase]);

  @override
  String toString() => 'InputModel{type: $type, pascalCase: $pascalCase}';

  /// convert [InputModel] to [TypeExtension]
  TypeExtension typeExt(int length) => TypeExtension(
        type: type,
        name: pascalCase.sublist(length).join(),
      );
}
