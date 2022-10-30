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
