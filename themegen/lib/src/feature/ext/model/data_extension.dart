import 'package:analyzer/dart/element/type.dart';

class DataExtension {
  final String dataClassName;
  final Set<DartType> extensions;
  final int index;

  DataExtension(
    this.dataClassName,
    this.extensions,
    this.index,
  );
}
