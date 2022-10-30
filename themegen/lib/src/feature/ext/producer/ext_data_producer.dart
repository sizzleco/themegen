import 'package:code_builder/code_builder.dart';
import 'package:themegen/src/core/logic/code_producer.dart';
import 'package:themegen/src/feature/ext/model/data_extension.dart';
import 'package:themegen/src/feature/ext/producer/ext_producer.dart';

class ExtDataProducer extends CodeProducer<DataExtension> {
  ExtDataProducer(super.emitter, this._extProducer);

  final ExtProducer _extProducer;

  @override
  Spec spec(DataExtension input) {
    return Library(
      (builder) => builder.body
        ..addAll(
          input.extensions.map(_extProducer.spec),
        ),
    );
  }
}
