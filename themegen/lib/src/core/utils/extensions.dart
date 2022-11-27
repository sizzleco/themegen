import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:pure/pure.dart';
import 'package:themegen/src/feature/ext/model/elements.dart';

extension StringX on String {
  String get capitalized => this[0].toUpperCase() + substring(1);

  String get lowerCaseFirst => this[0].toLowerCase() + substring(1);

  List<String> splitPascalCase() {
    final input = this;
    final result = <String>[];
    var buffer = StringBuffer();
    for (var i = 0; i < input.length; i++) {
      final char = input[i];
      final isUpper = char.codeUnitAt(0) >= 65 && char.codeUnitAt(0) <= 90;
      if (isUpper) {
        if (buffer.isNotEmpty) {
          result.add(buffer.toString());
          buffer = StringBuffer();
        }
      }
      buffer.write(char);
    }
    if (buffer.isNotEmpty) {
      result.add(buffer.toString());
    }
    return result;
  }
}

extension ListX<T> on Iterable<T> {
  String joinParams([String separator = '']) {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return '';
    final buffer = StringBuffer();
    if (separator == '') {
      do {
        buffer.write(iterator.current.toString());
      } while (iterator.moveNext());
    } else {
      do {
        buffer
          ..write(iterator.current.toString())
          ..write(separator);
      } while (iterator.moveNext());
    }
    return buffer.toString();
  }
}

extension WhereX<E extends Element> on Iterable<E> {
  Iterable<E> whereAnnotatedWith<T>() => where(
        (element) {
          final annotated = element.metadata.any(
            (element) => element.element?.displayName == T.toString(),
          );
          return annotated;
        },
      );

  Iterable<ElementAnnotation> annotationsOf<T>() => expand(
        (element) => element.metadata.where(
          (element) => element.element?.displayName == T.toString(),
        ),
      );
}

extension UniqueNestedX<T> on Iterable<Iterable<T?>?> {
  List<T> get unique {
    final list = <T>[];
    forEach((element) {
      for (final element in element ?? <T>[]) {
        if (element == null) continue;
        list
          ..remove(element)
          ..add(element);
      }
    });
    return list;
  }
}

extension MethodX on MethodElement {
  List<ExtensionParameter> getParamsForMethod() {
    final element = this;
    final session = element.session;
    final parsed = session?.getParsedLibraryByElement(element.library) as ParsedLibraryResult?;
    final declaration = parsed?.getElementDeclaration(element);
    final node = declaration?.node;
    if (node == null) return [];
    Token? token = node.beginToken;
    final types = <ExtensionParameter>[];

    var isParenthesis = false;
    while (token != null && token != node.endToken) {
      if (token?.type == TokenType.CLOSE_PAREN) {
        isParenthesis = false;
        break;
      }
      token = token?.next;
      if (token?.type == TokenType.OPEN_PAREN) {
        isParenthesis = true;
        continue;
      }

      if (isParenthesis) {
        final lexeme = token?.lexeme;
        if (lexeme != null && lexeme != ',') {
          Tram<String> isolateParameters(String combinedLexeme, Token? t) {
            token = t?.next;
            if (token == null ||
                token?.type == TokenType.CLOSE_PAREN ||
                token?.type == TokenType.COMMA ||
                token!.isEof) {
              return Tram.done(combinedLexeme);
            }
            final combined = '$combinedLexeme $token';

            return Tram.call(() => isolateParameters(combined, token));
          }

          final parameter = isolateParameters.bounce(lexeme, token);
          final split = parameter.split(' ');
          // only decorators
          final decorators = split.where((token) => token.startsWith('@')).toList();
          final tokensNoDecorators = split.sublist(decorators.length);
          // default type is dynamic
          var type = 'dynamic';
          if (tokensNoDecorators.length == 2) {
            type = tokensNoDecorators[0];
          }
          final name = tokensNoDecorators.last;
          types.add(
            ExtensionParameter(
              name: name,
              decorators: decorators,
              type: type,
            ),
          );
        }
      }
    }
    return types;
  }
}

extension MethodListX on Iterable<MethodElement> {
  Iterable<ExtensionParameter> paramsForMethods() => map(
        (e) => e.getParamsForMethod(),
      ).expand((e) => e);
}
