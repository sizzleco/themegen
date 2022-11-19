import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:collection/collection.dart';
import 'package:themegen/src/core/logic/code_producer.dart';
import 'package:themegen/src/core/utils/extension.dart';
import 'package:themegen/src/feature/ext/model/extension.dart' as model;
import 'package:themegen/src/feature/ext/model/extension.dart';
import 'package:themegen/src/feature/ext/model/input_model.dart';
import 'package:themegen/src/feature/ext/producer/ext_producer.dart';

class ThemeProducer extends CodeProducer<Set<DartType>> {
  ThemeProducer(super.emitter, this._extProducer);

  final ExtProducer _extProducer;
  static final extensions = <String, model.Extension>{};

  static bool whereNotUnderscore(String string) => !string.startsWith('_');

  @override
  Spec spec(Set<DartType> input) {
    // e.g. for _$AppColorsLight, _$AppColorsDark, _$AppFontStylesLight, _$AppFontStylesDark it will be
    // {
    //   'AppColors': {
    //     'light': _$AppColorsLight,
    //     'dark': _$AppColorsDark,
    //   },
    //   'AppFontStyles': {
    //     'light': _$AppFontStylesLight,
    //     'dark': _$AppFontStylesDark,
    //   },
    // }
    final splittedByPascalCase = input
        .map(
          (e) => e.getDisplayString(withNullability: false).splitPascalCase(),
        )
        .map((e) => e.where(whereNotUnderscore).toList());

    final inputModels = splittedByPascalCase.mapIndexed(
      (index, e) => InputModel(input.elementAt(index), e),
    );

    final extensionResults = <String, Set<TypeExtension>>{};
    final addedExtensions = <InputModel>{};
    for (final el1 in inputModels) {
      for (final el2 in inputModels) {
        if (el1.pascalCase.join() == el2.pascalCase.join()) continue;

        var index = 0;

        // find common part from the start for both arrays
        final common = el1.pascalCase.takeWhile(
          (value) {
            if (el2.pascalCase.length <= index) return false;
            final shouldTake = value == el2.pascalCase.elementAt(index);
            index++;
            return shouldTake;
          },
        ).toList();
        if (common.length >= 2) {
          final key = common.join();
          extensionResults[key] ??= {};
          extensionResults[key]!.add(el1.typeExt(common.length));
          extensionResults[key]!.add(el2.typeExt(common.length));
          addedExtensions.addAll([el1, el2]);
        }
      }
    }

    print('extensionResults: $extensionResults');

    for (final inputModel in inputModels) {
      if (addedExtensions.any((element) => element.type == inputModel.type)) continue;
      final key = inputModel.pascalCase.join();
      extensionResults[key] ??= {};
      extensionResults[key]!.add(inputModel.typeExt(0));
    }

    print('extensionResults: $extensionResults');

    final extensions = extensionResults.entries.map(
      (e) => model.Extension(
        name: e.key,
        types: e.value,
      ),
    );

    return Library(
      (builder) => builder
        ..body.addAll(
          extensions.map(_extProducer.spec),
        ),
    );
  }
}
