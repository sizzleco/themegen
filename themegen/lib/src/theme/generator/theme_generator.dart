import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:themegen/src/core/generator/annotated_class_field_generator.dart';
import 'package:themegen/src/theme/model/theme_model.dart';
import 'package:themegen_annotation/themegen_annotation.dart';

class ThemeGenerator extends AnnotatedClassFieldGenerator<ThemeGen, ThemeModel> {
  ThemeGenerator({
    required super.producer,
    required super.allowedEntity,
  });

  @override
  Iterable<ThemeModel> extractFieldInfo(
    ClassElement thisElement,
    ConstantReader annotation,
  ) sync* {
    yield ThemeModel(
      title: annotation.read('title').isNull //
          ? thisElement.name
          : annotation.read('title').stringValue,
      extensions: annotation
          .read('styles')
          .setValue
          .map((e) => e.toTypeValue()?.element2)
          .whereType<ClassElement>()
          .toList(growable: false),
    );
  }
}
