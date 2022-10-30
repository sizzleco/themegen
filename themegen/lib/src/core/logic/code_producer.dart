import 'package:code_builder/code_builder.dart';

abstract class CodeProducer<T> {
  CodeProducer(this._emitter);

  final DartEmitter _emitter;

  Spec spec(T input);

  String produce(T input) {
    return spec(input).accept(_emitter).toString();
  }
}
