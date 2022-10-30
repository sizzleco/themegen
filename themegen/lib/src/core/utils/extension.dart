import 'package:analyzer/dart/element/element.dart';

extension StringX on String {
  String get capitalized => this[0].toUpperCase() + substring(1);
}

extension WhereX<E extends Element> on Iterable<E> {
  Iterable<E> whereAnnotatedWith<T>() {
    return where(
      (element) {
        final annotated = element.metadata.any(
          (element) => element.element?.displayName == T.toString(),
        );
        return annotated;
      },
    );
  }

  Iterable<ElementAnnotation> annotationsOf<T>() {
    return expand(
      (element) => element.metadata.where(
        (element) => element.element?.displayName == T.toString(),
      ),
    );
  }
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
