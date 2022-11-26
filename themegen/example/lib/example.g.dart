// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example.dart';

// **************************************************************************
// ThemeGenerator
// **************************************************************************

class AppColors extends ThemeExtension<AppColors> {
  AppColors({
    required this.primary,
    required this.secondary,
  });

  AppColors._lerp({
    required Color primary,
    required Color secondary,
    required double t,
    required AppColors other,
  })  : primary = Color.lerp(primary, other.primary, t)!,
        secondary = Color.lerp(secondary, other.secondary, t)!;

  final Color primary;

  final Color secondary;

  @factory
  static AppColors light({
    Color? primary,
    Color? secondary,
  }) =>
      AppColors(
        primary: primary ?? _$AppColorsLight.primary,
        secondary: secondary ?? _$AppColorsLight.secondary,
      );
  @factory
  static AppColors dark({
    Color? primary,
    Color? secondary,
  }) =>
      AppColors(
        primary: primary ?? _$AppColorsDark.primary,
        secondary: secondary ?? _$AppColorsDark.secondary,
      );
  @override
  AppColors lerp(
    ThemeExtension<AppColors>? other,
    double t,
  ) {
    if (other is! AppColors) {
      return this;
    }
    return AppColors._lerp(
      other: other,
      t: t,
      primary: primary,
      secondary: secondary,
    );
  }

  @override
  AppColors copyWith({
    Color? primary,
    Color? secondary,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
    );
  }
}

class AppFontStyles extends ThemeExtension<AppFontStyles> {
  AppFontStyles({
    required TextStyle Function(AppColors) h1,
    required AppColors colors,
  })  : h1 = h1(colors),
        _$h1 = h1,
        colors = colors;

  AppFontStyles._lerp({
    required TextStyle Function(AppColors) h1,
    required AppColors colors,
    required double t,
    required AppFontStyles other,
  })  : h1 = TextStyle.lerp(h1(colors), other._$h1(colors), t)!,
        _$h1 = h1,
        colors = colors;

  final AppColors colors;

  final TextStyle h1;

  final TextStyle Function(AppColors colors) _$h1;

  @factory
  static AppFontStyles light({
    TextStyle Function(AppColors)? h1,
    required AppColors colors,
  }) =>
      AppFontStyles(
        h1: h1 ?? _$AppFontStylesLight.h1,
        colors: colors,
      );
  @factory
  static AppFontStyles dark({
    TextStyle Function(AppColors)? h1,
    required AppColors colors,
  }) =>
      AppFontStyles(
        h1: h1 ?? _$AppFontStylesDark.h1,
        colors: colors,
      );
  @override
  AppFontStyles lerp(
    ThemeExtension<AppFontStyles>? other,
    double t,
  ) {
    if (other is! AppFontStyles) {
      return this;
    }
    return AppFontStyles._lerp(
      other: other,
      t: t,
      h1: _$h1,
      colors: colors,
    );
  }

  @override
  AppFontStyles copyWith({
    TextStyle Function(AppColors)? h1,
    AppColors? colors,
  }) {
    return AppFontStyles(h1: h1 ?? _$h1, colors: colors ?? this.colors);
  }
}

class AppBundles extends ThemeExtension<AppBundles> {
  AppBundles({required this.aboba});

  AppBundles._lerp({
    required Color aboba,
    required double t,
    required AppBundles other,
  }) : aboba = Color.lerp(aboba, other.aboba, t)!;

  final Color aboba;

  @factory
  static AppBundles appBundles({Color? aboba}) => AppBundles(
        aboba: aboba ?? _$AppBundles.aboba,
      );
  @override
  AppBundles lerp(
    ThemeExtension<AppBundles>? other,
    double t,
  ) {
    if (other is! AppBundles) {
      return this;
    }
    return AppBundles._lerp(
      other: other,
      t: t,
      aboba: aboba,
    );
  }

  @override
  AppBundles copyWith({Color? aboba}) {
    return AppBundles(
      aboba: aboba ?? this.aboba,
    );
  }
}
