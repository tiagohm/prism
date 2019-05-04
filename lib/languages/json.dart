import 'package:prism/language.dart';
import 'package:prism/rule.dart';

class Json extends Language {
  Json({
    bool allowComments = false,
  }) {
    this["property"] = [
      Rule(
        r'"(?:\\.|[^"\r\n])*"(?=\s*:)',
        greedy: true,
      ),
    ];
    this["string"] = [
      Rule(
        r'"(?:\\.|[^"\r\n])*"(?!\s*:)',
        greedy: true,
      ),
    ];
    if (allowComments) {
      this["comment"] = [
        Rule(r"\/\/.*|\/\*[\s\S]*?(?:\*\/|$)"),
      ];
    }
    this["number"] = [
      Rule(
        r"-?\d+\.?\d*(e[+-]?\d+)?",
        caseSensitive: false,
      ),
    ];
    this["punctuation"] = [
      Rule(r"[{}\[\],]"),
    ];
    this["operator"] = [
      Rule(":"),
    ];
    this["boolean"] = [
      Rule(r"\b(?:true|false)\b"),
    ];
    this["null"] = [
      Rule(r"\bnull\b"),
    ];
  }
}
