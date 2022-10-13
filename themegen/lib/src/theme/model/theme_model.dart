import 'package:analyzer/dart/element/element.dart';

class ThemeModel {
  const ThemeModel({
    required this.title,
    required this.extensions,
  });

  final String title;
  final List<ClassElement> extensions;

  @override
  String toString() => 'ThemeModel(title: $title, extensions: $extensions)';
}
