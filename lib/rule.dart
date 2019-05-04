import 'package:prism/grammar.dart';

/// Representa uma regra.
class Rule {
  final RegExp pattern;
  final bool greedy;
  final Grammar inside;

  Rule(
    String pattern, {
    bool caseSensitive = true,
    bool multiLine = false,
    bool greedy = false,
    Grammar inside,
  })  : pattern = RegExp(
          pattern,
          caseSensitive: caseSensitive,
          multiLine: multiLine,
        ),
        greedy = greedy,
        inside = inside;
}
