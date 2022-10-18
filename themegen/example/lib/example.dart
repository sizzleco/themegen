import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:themegen_annotation/themegen_annotation.dart';

part 'example.g.dart';

@ThemeGen(extensions: {
  _$AppColorsLight,
})
class _$AppThemeLight {}

@ThemeGen(extensions: {
  _$AppColorsDark,
})
class _$AppThemeDark {}

@ThemeGenExtension(group: 'AppColors')
class _$AppColorsLight {
  static const Color primary = Color(0xFF000000);
  static const Color secondary = Color(0xFF000000);
}

@ThemeGenExtension(group: 'AppColors')
class _$AppColorsDark {
  static const Color primary = Color(0xFF000000);
  static const Color secondary = Color(0xFF000000);
}

@ThemeGenExtension(group: 'AppFontStyles')
class _$AppFontStylesLight {
  static TextStyle h1(AppColors colors) => TextStyle(
        color: colors.primary,
      );
}

void main() => runZonedGuarded<Future<void>>(
      () async {
        runApp(const App());
      },
      (error, stackTrace) => log(
        'Top level exception',
        error: error,
        stackTrace: stackTrace,
        level: 1000,
        name: 'main',
      ),
    );

/// {@template app}
/// App widget
/// {@endtemplate}
class App extends StatelessWidget {
  /// {@macro app}
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    Theme.of(context).extension();
    return MaterialApp(
      theme: ThemeData(
        extensions: [],
      ),
      title: 'Material App',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Material App Bar'),
        ),
        body: const SafeArea(
          child: Center(
            child: Text('Hello World'),
          ),
        ),
      ),
    );
  }
} // App
