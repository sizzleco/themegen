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
    required TextStyle Function(AppColors, AppColors) h1,
    required AppColors appColors,
  })  : h1 = h1(appColors, appColors),
        _$h1 = h1,
        _$appColors = appColors;

  AppFontStyles._lerp({
    required TextStyle Function(AppColors, AppColors) h1,
    required AppColors appColors,
    required double t,
    required AppFontStyles other,
  })  : h1 = TextStyle.lerp(
            h1(appColors, appColors), other._$h1(appColors, appColors), t)!,
        _$h1 = h1,
        _$appColors = appColors;

  final TextStyle h1;

  final TextStyle Function(AppColors, AppColors) _$h1;

  final AppColors _$appColors;

  @factory
  static AppFontStyles light({
    TextStyle Function(AppColors, AppColors)? h1,
    required AppColors appColors,
  }) =>
      AppFontStyles(
        h1: h1 ?? _$AppFontStylesLight.h1,
        appColors: appColors,
      );
  @factory
  static AppFontStyles dark({
    TextStyle Function(AppColors, AppColors)? h1,
    required AppColors appColors,
  }) =>
      AppFontStyles(
        h1: h1 ?? _$AppFontStylesDark.h1,
        appColors: appColors,
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
      appColors: _$appColors,
    );
  }

  @override
  AppFontStyles copyWith({
    TextStyle Function(AppColors, AppColors)? h1,
    AppColors? appColors,
  }) {
    return AppFontStyles(h1: h1 ?? _$h1, appColors: appColors ?? _$appColors);
  }
}
