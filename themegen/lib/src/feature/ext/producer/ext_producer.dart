import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:themegen/src/core/logic/code_producer.dart';

class ExtProducer extends CodeProducer<DartType> {
  ExtProducer(super.emitter);

  @override
  Spec spec(DartType input) {
    final name = input.getDisplayString(withNullability: false);
    if (!name.startsWith('_\$')) {
      throw Exception('Extension name must start with "_\$"');
    }
    final alias = input.element2;
    if (alias == null && alias is! ClassElement) {
      throw Exception(
        'Invalid extension type, must be a class $input, '
        'but $alias',
      );
    }

    final generatedClassName = name.replaceAll('_\$', '');
    return Class(
      (builder) => builder..name = generatedClassName,
    );
  }

  
}
