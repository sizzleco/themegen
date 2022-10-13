library themegen_annotation;

const themegen = ThemeGen();

class ThemeGen {
  const ThemeGen({
    this.title,
    this.extensions = const {},
  });

  final String? title;
  final Set<Type> extensions;
}

class ThemeGenExtension {
  const ThemeGenExtension({
    this.title,
  });

  final String? title;
}
