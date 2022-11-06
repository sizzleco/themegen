import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:themegen/src/core/utils/extension.dart';
import 'package:themegen/src/feature/theme/theme_producer.dart';
import 'package:themegen_annotation/themegen_annotation.dart';

class ThemeGenerator extends Generator {
  const ThemeGenerator(this._themeProducer);
  final ThemeProducer _themeProducer;

  static const _typeChecker = TypeChecker.fromRuntime(ThemeGen);

  @override
  String generate(LibraryReader library, BuildStep buildStep) {
    // get classes only annotated with @ThemeGen
    final classes =
        library.annotatedWith(_typeChecker).map((e) => e.element).whereType<ClassElement>();
    // get only @ThemeGen annotations
    final metadatas = classes.annotationsOf<ThemeGen>();
    // get unique extensions from @ThemeGen annotations
    final extensions = metadatas
        .map((e) => e.computeConstantValue())
        .map<Iterable<DartType?>?>(
          (e) {
            final extensions = e?.getField('extensions')?.toSetValue();
            final types = extensions?.map((e) => e.toTypeValue());
            return types;
          },
        )
        .unique
        .toSet();

    return _themeProducer.produce(extensions);
  }
}
