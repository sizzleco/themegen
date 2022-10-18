library themegen;

import 'package:build/build.dart' as build;
import 'package:code_builder/code_builder.dart';
import 'package:source_gen/source_gen.dart' as source_gen;
import 'package:themegen/src/extension/generator/extension_generator.dart';
import 'package:themegen/src/extension/logic/extension_producer.dart';
import 'package:themegen/src/theme/generator/theme_generator.dart';
import 'package:themegen/src/theme/logic/theme_producer.dart';

build.Builder themeGen(build.BuilderOptions options) {
  final emitter = DartEmitter(useNullSafetySyntax: true);
  return source_gen.SharedPartBuilder(
    [
      ExtensionGenerator(
        producer: ExtensionProducer(emitter),
        allowedEntity: 'Class',
      ),
      ThemeGenerator(
        producer: ThemeProducer(emitter),
        allowedEntity: 'Class',
      ),
    ],
    'theme',
  );
}
