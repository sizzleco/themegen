library themegen_annotation;

const theme = ThemeGen();
const themeExtension = ThemeGenExtension();

class ThemeGen {
  const ThemeGen({
    this.title,
    this.styles = const {},
  });

  final String? title;
  final Set<Type> styles;
}

class ThemeGenExtension {
  const ThemeGenExtension({
    this.group,
  });

  final String? group;
}
