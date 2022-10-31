import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:themegen/src/core/logic/code_producer.dart';
import 'package:themegen/src/core/utils/extension.dart';
import 'package:themegen/src/feature/ext/model/data_extension.dart';
import 'package:themegen/src/feature/ext/model/similar_ext.dart';
import 'package:themegen/src/feature/ext/producer/ext_producer.dart';

class ThemeProducer extends CodeProducer<Set<DartType>> {
  ThemeProducer(super.emitter, this._extDataProducer);

  final ExtProducer _extDataProducer;

  @override
  Spec spec(Set<DartType> input) {
    // find similar extensions by its name
    // 65 - 90 - A - Z
    // 97 - 122 - a - z
    final splittedInput = input.map(
      (e) => e.getDisplayString(withNullability: false).splitPascalCase(),
    );
    // similar extensions
    final similarExtensions = <String, SimilarExt>{};
    for (final ext in splittedInput) {
      for (final ext2 in splittedInput) {
        var matching = 1;
        for (var i = 1; i < ext.length; i++) {
          final el = ext[i];
          final el2 = ext2[i];
          if (el == el2) {
            matching++;
          }
          if (el != el2 && matching > 2) {
            final key = ext.sublist(1, i).join();
            final types = input.where(
              (e) {
                final display = e.getDisplayString(withNullability: false);
                return display == ext.join() || display == ext2.join();
              },
            );
            final value = SimilarExt(
              (similarExtensions[key]?.types ?? <DartType>{})..addAll(types),
              matching,
            );
            similarExtensions[key] = value;
            break;
          }
        }
      }
    }
    for (final element in input) {
      final isSimilar = similarExtensions.values.any(
        (e) => e.types.contains(element),
      );
      if (isSimilar) {
        continue;
      }
      similarExtensions[element
          .getDisplayString(withNullability: false)
          .splitPascalCase()
          .sublist(1)
          .join()] = SimilarExt({element}, 1);
    }

    return Library(
      (builder) => builder
        ..body.addAll(
          similarExtensions.entries.map(
            (e) => _extDataProducer.spec(
              DataExtension(e.key, e.value.types, e.value.index),
            ),
          ),
        ),
    );
  }
}
