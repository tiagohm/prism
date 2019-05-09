import 'package:prism/grammar.dart';
import 'package:prism/language.dart';
import 'package:prism/rule.dart';

class Markup extends Language {
  Markup() {
    this["comment"] = [
      Rule(r"<!--[\s\S]*?-->"),
    ];
    this["prolog"] = [
      Rule(r"<\?[\s\S]+?\?>"),
    ];
    this["doctype"] = [
      Rule(
        r"<!DOCTYPE[\s\S]+?>",
        caseSensitive: false,
      ),
    ];
    this["cdata"] = [
      Rule(
        r"<!\[CDATA\[[\s\S]*?]]>",
        caseSensitive: false,
      )
    ];
    this["tag"] = [
      Rule(
        r"""<\/?(?!\d)[^\s>\/=$<%]+(?:\s(?:\s*[^\s>\/=]+(?:\s*=\s*(?:"[^"]*"|'[^']*'|[^\s'">=]+(?=[\s>]))|(?=[\s/>])))+)?\s*\/?>""",
        greedy: true,
        inside: Grammar()
          ..["tag"] = [
            Rule(
              r"^<\/?[^\s>\/]+",
              caseSensitive: false,
              inside: Grammar()
                ..["punctuation"] = [
                  Rule(r"^<\/?"),
                ]
                ..["namespace"] = [
                  Rule(r"^[^\s>\/:]+:"),
                ],
            ),
          ]
          ..["attr-value"] = [
            Rule(
              r"""=\s*(?:"[^"]*"|'[^']*'|[^\s'">=]+)""",
              caseSensitive: false,
              inside: Grammar()
                ..["punctuation"] = [
                  Rule("^="),
                  Rule(
                    r"""^(\s*)["']|["']$""",
                    lookbehind: true,
                  ),
                ],
            ),
          ]
          ..["punctuation"] = [
            Rule(r"\/?>"),
          ]
          ..["attr-name"] = [
            Rule(
              r"[^\s>\/]+",
              inside: Grammar()
                ..["namespace"] = [
                  Rule(r"^[^\s>\/:]+:"),
                ],
            ),
          ],
      ),
    ];
    this["entity"] = [
      Rule(
        r"&#?[\da-z]{1,8};",
        caseSensitive: false,
      ),
    ];

    this["tag"][0].inside["attr-value"][0].inside["entity"] = this["entity"];

    // TODO: addInlined()
  }
}

class Xml extends Markup {}

class Html extends Markup {}

class Mathtml extends Markup {}

class Svg extends Markup {}
