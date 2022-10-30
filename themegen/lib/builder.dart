library themegen;

import 'package:build/build.dart' as build;
import 'package:code_builder/code_builder.dart';
import 'package:source_gen/source_gen.dart' as source_gen;
import 'package:themegen/src/feature/ext/producer/ext_data_producer.dart';
import 'package:themegen/src/feature/ext/producer/ext_producer.dart';
import 'package:themegen/src/feature/theme/theme_generator.dart';
import 'package:themegen/src/feature/theme/theme_producer.dart';

build.Builder themeGen(build.BuilderOptions options) {
  final emitter = DartEmitter(useNullSafetySyntax: true);
  return source_gen.SharedPartBuilder(
    [
      ThemeGenerator(
        ThemeProducer(
          emitter,
          ExtDataProducer(emitter, ExtProducer(emitter)),
        ),
      ),
    ],
    'theme',
  );
}
