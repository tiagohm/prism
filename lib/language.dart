import 'package:prism/grammar.dart';
import 'package:prism/rule.dart';
import 'package:prism/token.dart';

typedef HighlightMapper<T> = T Function(
  String name,
  String text,
  int start,
  int end,
);

/// Representa uma linguagem.
abstract class Language extends Grammar {
  // static final _nonWhitespaceRegex = RegExp(r"\S+");

  Language({
    Grammar rest,
  }) : super(rest: rest);

  /*
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
      print("$token");
      final end = start + token.length;
      // Ignora espaços.
      if (!ignoreWhitespaces || _nonWhitespaceRegex.hasMatch(text)) {
        res.add(mapper(name, text, start, end));
      }
      start += text.length;
    }
    return res;
  }
  */

  List<Token> tokenize(String text) => _tokenize(text, this);

  List<Token> _tokenize(
    String text,
    Grammar grammar,
  ) {
    // rest representa o resto do rule que pode estar definido em outro lugar.
    if (grammar.rest != null) {
      grammar.combineWith(grammar.rest);
    }

    final List buffer = <Token>[StringToken(text)];
    _matchGrammar(text, buffer, grammar, 0, 0, false);
    return buffer;
  }

  void _matchGrammar(
    String text,
    List<Token> buffer,
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
          if (buffer[i] is RuleToken) {
            pos += buffer[i].length;
            i++;
            continue;
          }

          var str = (buffer[i] as StringToken).value;

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
                    (buffer[k] is StringToken && !buffer[k - 1].greedy))) {
              p += buffer[k].length;
              // Move the index i to the element in buffer that is closest to from
              if (from >= p) {
                i++;
                pos = p;
              }

              k++;
            }

            // If strarr[i] is a Token, then the match starts inside another Token, which is invalid
            if (buffer[i] is RuleToken) {
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
          final args = List<Token>();

          if (before.isNotEmpty) {
            i++;
            pos += before.length;
            args.add(StringToken(before));
          }

          List<Token> content;
          if (rule.inside != null && rule.inside.isNotEmpty) {
            content = _tokenize(matchStr, rule.inside);
          } else {
            content = [StringToken(matchStr)];
          }

          final token = RuleToken(rule, name, content, matchStr.length);
          args.add(token);

          if (after.isNotEmpty) {
            args.add(StringToken(after));
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
