import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:prism/language.dart';
import 'package:prism/token.dart';

void testFeature(Language language, String name) {
  test(name, () {
    name = name.replaceAll(" ", "_");
    final filename = "${language.runtimeType}_$name.text".toLowerCase();
    final inputText = File("./test/input/$filename").readAsStringSync();
    final expectedOutputText =
        File("./test/output/$filename").readAsStringSync();
    final actualOutputText = _prettyPrint(language.tokenize(inputText));
    expect(actualOutputText, expectedOutputText);
  });
}

String _prettyPrint(List<Token> tokens, [Token parent]) {
  final out = StringBuffer();

  for (final item in tokens) {
    if (item is StringToken) {
      // Nada.
      if (item.value.length == 0) {
        continue;
      }
      // Quebra de linha.
      else if (item.value == "\n") {
        out.write(item.value);
      }
      // Token.
      else {
        if (item.name != "text") {
          out.writeln(item.name);
        } else if (parent != null) {
          out.writeln(parent.name);
        } else {
          out.writeln("text");
        }

        // Vários espaços em branco.
        if (item.value.trim().length == 0) {
          out.writeln("[${item.value.length}]");
        } else {
          out.writeln(item.value);
        }
      }
    }
    // Composição de outros tokens.
    else {
      out.write(_prettyPrint(item.content, item));
    }
  }

  return out.toString();
}
