import 'package:prism/src/grammar.dart';

/// Representa uma regra.
class Rule {
  final RegExp pattern;
  final bool greedy;
   final bool lookbehind;
  final Grammar inside;

  Rule(
    String pattern, {
    bool caseSensitive = true,
    bool multiLine = false,
    this.greedy = false,
    this.lookbehind = false,
    this.inside,
  })  : pattern = RegExp(
          pattern,
          caseSensitive: caseSensitive,
          multiLine: multiLine,
        );
}
