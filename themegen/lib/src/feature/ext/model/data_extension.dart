import 'package:analyzer/dart/element/type.dart';

class DataExtension {
  final String dataClassName;
  final Set<DartType> extensions;

  DataExtension(this.dataClassName, this.extensions);
}
