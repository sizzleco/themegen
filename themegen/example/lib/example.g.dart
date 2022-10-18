// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example.dart';

// **************************************************************************
// ExtensionGenerator
// **************************************************************************

class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.secondary,
  });

  final Color primary;

  final Color secondary;

  @override
  AppColors copyWith({
    Color? primary,
    Color? secondary,
  }) {
    return AppColors(
        primary: primary ?? this.primary,
        secondary: secondary ?? this.secondary);
  }

  @override
  AppColors lerp(
    ThemeExtension<AppColors>? other,
    double t,
  ) {
    if (other is! AppColors) {
      return this;
    }
    return AppColors(
        primary: Color.lerp(primary, other.primary, t)!,
        secondary: Color.lerp(secondary, other.secondary, t)!);
  }
}

class AppColorsLight extends AppColors {
  const AppColorsLight({
    super.primary = _$AppColorsLight.primary,
    super.secondary = _$AppColorsLight.secondary,
  });
}

class AppColorsDark extends AppColors {
  const AppColorsDark({
    super.primary = _$AppColorsDark.primary,
    super.secondary = _$AppColorsDark.secondary,
  });
}

class AppFontStyles extends ThemeExtension<AppFontStyles> {
  const AppFontStyles({dynamic colors});

  final TextStyle h1;

  @override
  AppFontStyles copyWith() {
    return AppFontStyles();
  }

  @override
  AppFontStyles lerp(
    ThemeExtension<AppFontStyles>? other,
    double t,
  ) {
    if (other is! AppFontStyles) {
      return this;
    }
    return AppFontStyles();
  }
}

class AppFontStylesLight extends AppFontStyles {
  const AppFontStylesLight({required dynamic super.colors});
}

// **************************************************************************
// ThemeGenerator
// **************************************************************************

class AppThemeLight {}

class AppThemeDark {}
