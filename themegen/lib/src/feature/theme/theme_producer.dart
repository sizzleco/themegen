import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:themegen/src/core/logic/code_producer.dart';
import 'package:themegen/src/feature/ext/model/data_extension.dart';
import 'package:themegen/src/feature/ext/producer/ext_data_producer.dart';

class ThemeProducer extends CodeProducer<Set<DartType>> {
  ThemeProducer(super.emitter, this._extDataProducer);

  final ExtDataProducer _extDataProducer;

  @override
  Spec spec(Set<DartType> input) {
    // find similar extensions by its name
    // 65 - 90 - A - Z
    // 97 - 122 - a - z
    final splittedInput = input.map(
      (e) => splitPascalCase(
        e.getDisplayString(withNullability: false),
      ),
    );
    // similar extensions
    final similarExtensions = <String, Set<DartType>>{};
    for (final ext in splittedInput) {
      for (final ext2 in splittedInput) {
        var matching = 0;
        for (var i = 1; i < ext.length; i++) {
          final el = ext[i];
          final el2 = ext2[i];
          if (el == el2) {
            matching++;
            continue;
          }
          if (el != el2 && matching > 1) {
            final key = ext.sublist(0, i).join();
            final value = (similarExtensions[key] ?? <DartType>{})
              ..addAll(
                input.where(
                  (e) {
                    final display = e.getDisplayString(withNullability: false);
                    return display == ext.join() || display == ext2.join();
                  },
                ),
              );
            similarExtensions[key] = value;
            continue;
          }
        }
      }
    }

    return Library(
      (builder) => builder
        ..body.addAll(
          similarExtensions.entries.map(
            (e) => _extDataProducer.spec(
              DataExtension(e.key, e.value),
            ),
          ),
        ),
    );
  }

  List<String> splitPascalCase(String input) {
    final result = <String>[];
    var buffer = StringBuffer();
    for (var i = 0; i < input.length; i++) {
      final char = input[i];
      final isUpper = char.codeUnitAt(0) >= 65 && char.codeUnitAt(0) <= 90;
      if (isUpper) {
        if (buffer.isNotEmpty) {
          result.add(buffer.toString());
          buffer = StringBuffer();
        }
      }
      buffer.write(char);
    }
    if (buffer.isNotEmpty) {
      result.add(buffer.toString());
    }
    return result;
  }
}
