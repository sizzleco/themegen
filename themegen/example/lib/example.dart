import 'package:flutter/widgets.dart';
import 'package:themegen_annotation/themegen_annotation.dart';

part 'example.g.dart';

@ThemeGen(extensions: {
  AppColors,
})
class AppTheme with _$AppTheme {}

@ThemeGenExtension()
class AppColors {
  static const Color primary = Color(0xFF000000);
  static const Color secondary = Color(0xFF000000);
}
