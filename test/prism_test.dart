import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:prism/prism.dart';
import 'package:prism/src/token.dart';

void main() {
  // https://github.com/PrismJS/prism/tree/master/tests/languages

  final json = Json();
  final jsonWithComments = Json(allowComments: true);
  final markup = Markup();

  test("Large text", () {
    final sw = Stopwatch();

    sw.start();
    final spans = json.tokenize(
      File("./large.json").readAsStringSync(),
      (name) {
        return null;
      },
    );
    sw.stop();

    print(countSpans(spans));
    print(sw.elapsedMilliseconds);
  });
}

int countSpans(List<Token> tokens) {
  var c = 0;

  for (final token in tokens) {
    if (token.children != null && token.children.isNotEmpty) {
      c += countSpans(token.children);
    }

    c++;
  }

  return c;
}
