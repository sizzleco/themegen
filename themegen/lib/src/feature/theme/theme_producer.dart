import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:collection/collection.dart';
import 'package:themegen/src/core/logic/code_producer.dart';
import 'package:themegen/src/core/utils/extensions.dart';
import 'package:themegen/src/feature/ext/logic/ext_producer.dart';
import 'package:themegen/src/feature/ext/model/extension_model.dart' as model;
import 'package:themegen/src/feature/ext/model/extension_model.dart';
import 'package:themegen/src/feature/ext/model/input_model.dart';

class ThemeProducer extends CodeProducer<Set<DartType>> {
  ThemeProducer(super.emitter, this._extProducer);

  final ExtProducer _extProducer;
  static final extensions = <String, model.ParentExtension>{};

  static bool whereNotUnderscore(String string) => !string.startsWith('_');

  @override
  Spec spec(Set<DartType> input) {
    // an algorigthm to find all the similar extensions, split them on groups
    // for _$AppColorsLight, _$AppColorsDark, _$AppFontStylesLight, _$AppFontStylesDark it will be
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
    // firstly, we split classes by pascal case
    final splittedByPascalCase = input
        .map(
          (e) => e.getDisplayString(withNullability: false).splitPascalCase(),
        )
        // remove underscore
        .map((e) => e.where(whereNotUnderscore).toList());

    final inputModels = splittedByPascalCase.mapIndexed(
      (index, pascalCased) => InputModel(input.elementAt(index), pascalCased),
    );

    /// similar extensions where key is a name of extension,
    /// and value is a set of other styles of the same extension
    final extensionResults = <String, Set<ExtensionType>>{};
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
        // If common part is bigger than 1, it means that we found similar extensions
        // still, a discussion question
        // it is considered that each style should have some prefix, for example App
        // but, if prefix consists of 2 words(in pascal case) this won't work correct
        // so it is needed to dynamically find the prefix. See themegen#11
        if (common.length >= 2) {
          final key = common.join();
          extensionResults[key] ??= {};
          extensionResults[key]!.add(el1.typeExt(common.length));
          extensionResults[key]!.add(el2.typeExt(common.length));
          addedExtensions.addAll([el1, el2]);
        }
      }
    }
    // find extensions that are not similar to any other
    // if an extension is not similar then it is considered as a base extension
    // that can be reused in themes
    for (final inputModel in inputModels) {
      if (addedExtensions.any((element) => element.type == inputModel.type)) continue;
      final key = inputModel.pascalCase.join();
      extensionResults[key] ??= {};
      extensionResults[key]!.add(inputModel.typeExt(0));
    }
    // convert extensions to model
    final extensions = extensionResults.entries.map(
      (e) => model.ParentExtension(
        name: e.key,
        types: e.value,
      ),
    );
    // generate extension code
    return Library(
      (builder) => builder
        ..body.addAll(
          extensions.map(_extProducer.spec),
        ),
    );
  }
}
