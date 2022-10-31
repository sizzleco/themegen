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

  final Color primary;

  final Color secondary;

  @factory
  static AppColors light() => AppColors(
      primary: _$AppColorsLight.primary, secondary: _$AppColorsLight.secondary);
  @factory
  static AppColors dark() => AppColors(
      primary: _$AppColorsDark.primary, secondary: _$AppColorsDark.secondary);
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

  @override
  AppColors copyWith({
    Color? primary,
    Color? secondary,
  }) {
    return AppColors(
        primary: primary ?? this.primary,
        secondary: secondary ?? this.secondary);
  }
}

class AppFontStyles extends ThemeExtension<AppFontStyles> {
  AppFontStyles();

  @factory
  static AppFontStyles appFontStyles() => AppFontStyles();
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

  @override
  AppFontStyles copyWith() {
    return AppFontStyles();
  }
}
