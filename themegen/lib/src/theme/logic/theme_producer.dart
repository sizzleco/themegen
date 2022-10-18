import 'package:code_builder/code_builder.dart';
import 'package:themegen/src/core/generator/code_producer.dart';
import 'package:themegen/src/theme/model/theme_model.dart';

class ThemeProducer extends BuilderCodeProducer<Set<ThemeModel>> {
  ThemeProducer(super.emitter);

  @override
  Spec spec(String className, Set<ThemeModel> info) {
    return Class(
      (p0) => p0
        ..name = info.first.title
            .replaceAll(
              r'$',
              '',
            )
            .replaceAll(
              '_',
              '',
            ),
    );
  }
}
