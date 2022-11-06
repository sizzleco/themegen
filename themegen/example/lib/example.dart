import 'package:flutter/material.dart';
import 'package:themegen_annotation/themegen_annotation.dart';

part 'example.g.dart';

@ThemeGen(
  extensions: {
    _$AppColorsLight,
    _$AppFontStylesLight,
  },
)
abstract class _$AppThemeLight {}

@ThemeGen(
  extensions: {
    _$AppColorsDark,
    _$AppFontStylesDark,
  },
)
class _$AppThemeDark {}

class _$AppColorsLight {
  static const Color primary = Color(0xFF000000);
  static const Color secondary = Color(0xFF000000);
}

class _$AppColorsDark {
  static const Color primary = Color(0xFF000000);
  static const Color secondary = Color(0xFF000000);
}

class _$AppFontStylesLight {
  static TextStyle h1(AppColors colors, AppColors colors2) => TextStyle(
        color: colors.primary,
      );
}

class _$AppFontStylesDark {
  static TextStyle h1(AppColors colors, AppColors colors2) => TextStyle(
        color: colors.primary,
      );
}
