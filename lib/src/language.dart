import 'package:flutter/material.dart';
import 'package:prism/src/grammar.dart';
import 'package:prism/src/rule.dart';
import 'package:prism/src/token.dart';

typedef Highlighter = TextStyle Function(String name);

/// Representa uma linguagem.
abstract class Language extends Grammar {
  Language({
    Grammar rest,
  }) : super(rest: rest);

  List<Token> tokenize(
    String text,
    Highlighter highlighter,
  ) {
    return _tokenize(
      text: text,
      grammar: this,
      highlighter: highlighter,
    );
  }

  static List<Token> _tokenize({
    String text,
    Grammar grammar,
    Highlighter highlighter,
  }) {
    // rest representa o resto do rule que pode estar definido em outro lugar.
    if (grammar.rest != null) {
      grammar.combineWith(grammar.rest);
    }

    final buffer = <Token>[StringToken(text)];

    _matchGrammar(
      text: text,
      buffer: buffer,
      grammar: grammar,
      highlighter: highlighter,
    );

    return buffer;
  }

  static void _matchGrammar({
    String text,
    List<Token> buffer,
    Grammar grammar,
    int index = 0,
    int startPos = 0,
    bool oneshot = false,
    String target,
    Highlighter highlighter,
  }) {
    for (final item in grammar.entries) {
      final String name = item.key;
      final List<Rule> rules = item.value;

      if (rules.isEmpty) continue;

      if (name == target) return;

      for (final rule in rules) {
        final greedy = rule.greedy;
        final regex = rule.pattern;
        final lookbehind = rule.lookbehind;

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

          var str = (buffer[i] as StringToken).text;

          // Something went terribly wrong, ABORT, ABORT!
          if (buffer.length > text.length) {
            return;
          }

          var delNum = 0;

          if (greedy && i != buffer.length - 1) {
            matches = regex.allMatches(text, pos);

            if (matches.isEmpty) {
              sair = true;
              continue;
            }

            final from = matches.first.start +
                (lookbehind ? matches.first.group(1).length : 0);
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
            matchIndex = matches.isEmpty ? 0 : matches.first.start;
            delNum = 1;
          }

          if (matches.isEmpty && oneshot) {
            sair = true;
            continue;
          }

          if (matches.isEmpty) {
            pos += buffer[i].length;
            i++;
            continue;
          }

          final lookbehindLength =
              lookbehind ? matches.first.group(1)?.length ?? 0 : 0;

          final from = matchIndex + lookbehindLength;
          final matchStr = matches.first.group(0).substring(lookbehindLength);
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
            content = _tokenize(
              text: matchStr,
              grammar: rule.inside,
            );
          } else if (matchStr.isNotEmpty) {
            content = [StringToken(matchStr)];
          } else {
            content = const [];
          }

          if (content.isNotEmpty) {
            final token = RuleToken(
              rule.greedy,
              matchStr.length,
              content,
              highlighter?.call(name),
            );
            args.add(token);
          }

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
            _matchGrammar(
              text: text,
              buffer: buffer,
              grammar: grammar,
              index: i,
              startPos: pos,
              oneshot: true,
              target: name,
            );
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
