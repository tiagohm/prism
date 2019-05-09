import 'package:prism/rule.dart';

/// Um token armazena informações de alguma regra casada durante o highlight.
abstract class Token {
  final String name;
  final List<Token> content;
  final int length;
  final bool greedy;

  Token(this.name, this.content, this.length, this.greedy);

  /// Obtém todo o texto.
  String text() => _stringify(this);

  static String _stringify(Token token) {
    if (token is StringToken) {
      return token.value;
    } else {
      final buffer = StringBuffer();
      for (final token in token.content) buffer.write(_stringify(token));
      return buffer.toString();
    }
  }
}

class StringToken extends Token {
  final String value;

  StringToken(this.value) : super("text", const [], value.length, false);

  @override
  String toString() {
    return "String: {name: $name, value: $value}";
  }
}

class RuleToken extends Token {
  final Rule rule;

  RuleToken(
    this.rule,
    String name,
    List<Token> content,
    int length,
  ) : super(name, content, length, rule.greedy);

  @override
  String toString() {
    return "$Rule: {name: $name, content: $content}";
  }
}
