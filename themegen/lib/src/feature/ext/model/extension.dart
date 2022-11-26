import 'package:analyzer/dart/element/type.dart';
import 'package:meta/meta.dart';

@immutable
class ParentExtension {
  final Set<ExtensionType> types;
  final String name;

  const ParentExtension({required this.types, required this.name});

  @override
  String toString() => 'Extension{types: $types, name: $name}';
}

@immutable
class ExtensionType {
  final DartType type;
  final String name;

  const ExtensionType({required this.type, required this.name});

  @override
  String toString() => 'TypeExtension{type: $type, name: $name}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtensionType &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          name == other.name;

  @override
  int get hashCode => Object.hashAll([runtimeType, type, name]);
}
