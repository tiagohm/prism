import 'package:prism/grammar.dart';
import 'package:prism/rule.dart';

/// Um token armazena informações de alguma regra casada durante o highlight.
abstract class _Token {
  final String name;
  final List<_Token> content;
  final int length;
  final bool greedy;

  _Token(this.name, this.content, this.length, this.greedy);

  static String _stringify(_Token token) {
    if (token is _StringToken) {
      return token.value;
    } else {
      return token.text();
    }
  }

  /// Obtém o texto da regra casada.
  String text() {
    if (this is _StringToken) {
      return (this as _StringToken).value;
    } else {
      final buffer = StringBuffer();
      for (_Token token in content) buffer.write(_stringify(token));
      return buffer.toString();
    }
  }
}

class _StringToken extends _Token {
  final String value;

  _StringToken(this.value) : super("text", const [], value.length, false);
}

class _RuleToken extends _Token {
  final Rule rule;

  _RuleToken(this.rule, String name, List<_Token> content, int length)
      : super(name, content, length, rule.greedy);
}

typedef HighlightMapper<T> = T Function(
  String name,
  String text,
  int start,
  int end,
);

/// Representa uma linguagem.
abstract class Language extends Grammar {
  static final _nonWhitespaceRegex = RegExp(r"\S+");

  Language({
    Grammar rest,
  }) : super(rest: rest);

  /// TODO: Uma rule pode ter uma parent???
  List<T> highlight<T>(
    String text, {
    bool ignoreWhitespaces = false,
    HighlightMapper<T> mapper,
  }) {
    final res = List<T>();
    final tokens = _tokenize(text, this);
    var start = 0;
    for (final token in tokens) {
      final text = token.text();
      final name = token.name;
      final end = start + token.length;
      // Ignora espaços.
      if (!ignoreWhitespaces || _nonWhitespaceRegex.hasMatch(text)) {
        res.add(mapper(name, text, start, end));
      }
      start += text.length;
    }
    return res;
  }

  List<_Token> _tokenize(
    String text,
    Grammar grammar,
  ) {
    // rest representa o resto do rule que pode estar definido em outro lugar.
    if (grammar.rest != null) {
      grammar.combineWith(grammar.rest);
    }

    final List buffer = <_Token>[_StringToken(text)];
    _matchGrammar(text, buffer, grammar, 0, 0, false);
    return buffer;
  }

  void _matchGrammar(
    String text,
    List<_Token> buffer,
    Grammar grammar,
    int index,
    int startPos,
    bool oneshot, {
    String target,
  }) {
    for (final item in grammar.entries) {
      final String name = item.key;
      final List<Rule> rules = item.value;

      if (rules.isEmpty) continue;

      if (name == target) return;

      for (final rule in rules) {
        final greedy = rule.greedy;
        final regex = rule.pattern;

        var i = index;
        var pos = startPos;
        Iterable<Match> matches;
        var matchIndex = 0;

        var sair = false;

        while (i < buffer.length && !sair) {
          if (buffer[i] is _RuleToken) {
            pos += buffer[i].length;
            i++;
            continue;
          }

          var str = (buffer[i] as _StringToken).value;

          // Something went terribly wrong, ABORT, ABORT!
          if (buffer.length > text.length) {
            return;
          }

          var delNum = 0;

          if (greedy && i != buffer.length - 1) {
            matches = regex.allMatches(text, pos);

            if (matches == null || matches.length == 0) {
              sair = true;
              continue;
            }

            final from = matches.first.start;
            final to = matches.first.start + matches.first.group(0).length;
            var k = i;
            var p = pos;

            final len = buffer.length;

            while (k < len &&
                (p < to ||
                    (buffer[k] is _StringToken && !buffer[k - 1].greedy))) {
              p += buffer[k].length;
              // Move the index i to the element in buffer that is closest to from
              if (from >= p) {
                i++;
                pos = p;
              }

              k++;
            }

            // If strarr[i] is a Token, then the match starts inside another Token, which is invalid
            if (buffer[i] is _RuleToken) {
              pos += buffer[i].length;
              i++;
              continue;
            }

            str = text.substring(pos, p);
            matchIndex = matches.first.start - pos;
            delNum = k - i;
          } else {
            matches = regex.allMatches(str, 0);
            matchIndex = (matches == null || matches.length == 0)
                ? 0
                : matches.first.start;
            delNum = 1;
          }

          if ((matches == null || matches.length == 0) && oneshot) {
            sair = true;
            continue;
          }

          if (matches == null || matches.length == 0) {
            pos += buffer[i].length;
            i++;
            continue;
          }

          final from = matchIndex;
          final matchStr = matches.first.group(0);
          final to = from + matchStr.length;
          final before = str.substring(0, from);
          final after = str.substring(to);
          final removeStart = i;
          final args = List<_Token>();

          if (before.isNotEmpty) {
            i++;
            pos += before.length;
            args.add(_StringToken(before));
          }

          List<_Token> content;
          if (rule.inside != null && rule.inside.isNotEmpty) {
            content = _tokenize(matchStr, rule.inside);
          } else {
            content = [_StringToken(matchStr)];
          }

          final token = _RuleToken(rule, name, content, matchStr.length);
          args.add(token);

          if (after.isNotEmpty) {
            args.add(_StringToken(after));
          }

          for (var x = 0; x < delNum; x++) {
            buffer.removeAt(removeStart);
          }

          for (var x = 0; x < args.length; x++) {
            buffer.insert(removeStart + x, args[x]);
          }

          if (delNum != 1) {
            _matchGrammar(text, buffer, grammar, i, pos, true, target: name);
          }

          if (oneshot) {
            sair = true;
            continue;
          }

          pos += buffer[i].length;
          i++;
        }
      }
    }
  }
}
