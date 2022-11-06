library themegen_annotation;

const theme = ThemeGen();

class ThemeGen {
  const ThemeGen({
    this.title,
    this.extensions = const {},
  });

  final String? title;
  final Set<Type> extensions;
}

class A {
  const A(this.a);

  final void Function() a;
}
