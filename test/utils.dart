import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:prism/language.dart';
import 'package:prism/token.dart';

void testFeature(Language language, String name) {
  test(name, () {
    final inputText =
        File("./test/input/${language.runtimeType}_$name.text".toLowerCase()).absolute
            .readAsStringSync();
    final expectedOutputText =
        File("./test/input/${language.runtimeType}_$name.text".toLowerCase()).absolute
            .readAsStringSync();
    final actualOutputText = _prettyPrint(language.tokenize(inputText), 0);
    print(actualOutputText);
  });
}

String _prettyPrint(List<Token> tokenStream, [int indentationLevel = 1]) {
  const indentChar = '\t';

  // can't use tabs because the console will convert one tab to four spaces
  final indentation = List(indentationLevel + 1).join(indentChar);

  final out = StringBuffer();
  out.write("[\n");
  var i = 0;
  for (final item in tokenStream) {
    out.write(indentation);

    if (item is StringToken) {
      out.write('"${item.value}"');
    } else {
      final name = item.name;
      final content = item.content;

      out.write('["$name", ');
      out.write(_prettyPrint(content, indentationLevel + 1));
      out.write(']');
    }

    final lineEnd = (i == tokenStream.length - 1) ? '\n' : ',\n';
    out.write(lineEnd);
  }

  out.write(indentation.substring(indentChar.length) + ']');
  return out.toString();
}
