import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:themegen/src/core/generator/annotated_class_field_generator.dart';
import 'package:themegen/src/extension/model/extension_model.dart';
import 'package:themegen_annotation/themegen_annotation.dart';

class ExtensionGenerator
    extends AnnotatedClassFieldGenerator<ThemeGenExtension, ExtensionModel> {
  ExtensionGenerator({
    required super.producer,
    required super.allowedEntity,
  });

  static bool _whereStatic<T extends ClassMemberElement>(T element) =>
      element.isStatic;

  @override
  Iterable<ExtensionModel> extractFieldInfo(
    ClassElement thisElement,
    ConstantReader annotation,
  ) sync* {
    yield ExtensionModel(
      group: annotation.read('group').isNull
          ? null
          : annotation.read('group').stringValue,
      fields: thisElement.fields.where(_whereStatic).toList(),
      methods: thisElement.methods.where(_whereStatic).toList(),
    );
  }
}
