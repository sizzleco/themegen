import 'package:analyzer/dart/element/type.dart';
import 'package:meta/meta.dart';

@immutable
class Extension {
  final Set<TypeExtension> types;
  final String name;

  const Extension({required this.types, required this.name});

  @override
  String toString() => 'Extension{types: $types, name: $name}';
}

@immutable
class TypeExtension {
  final DartType type;
  final String name;

  const TypeExtension({required this.type, required this.name});

  @override
  String toString() => 'TypeExtension{type: $type, name: $name}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TypeExtension &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          name == other.name;

  @override
  int get hashCode => Object.hashAll([runtimeType, type, name]);
}
