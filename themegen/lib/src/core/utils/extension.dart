import 'package:analyzer/dart/element/element.dart';

extension StringX on String {
  String get capitalized => this[0].toUpperCase() + substring(1);

  List<String> splitPascalCase() {
    final input = this;
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

extension WhereX<E extends Element> on Iterable<E> {
  Iterable<E> whereAnnotatedWith<T>() => where(
        (element) {
          final annotated = element.metadata.any(
            (element) => element.element?.displayName == T.toString(),
          );
          return annotated;
        },
      );

  Iterable<ElementAnnotation> annotationsOf<T>() => expand(
        (element) => element.metadata.where(
          (element) => element.element?.displayName == T.toString(),
        ),
      );
}

extension UniqueNestedX<T> on Iterable<Iterable<T?>?> {
  List<T> get unique {
    final list = <T>[];
    forEach((element) {
      for (final element in element ?? <T>[]) {
        if (element == null) continue;
        list
          ..remove(element)
          ..add(element);
      }
    });
    return list;
  }
}
