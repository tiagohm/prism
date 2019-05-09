import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:prism/language.dart';
import 'package:prism/span.dart';

void testFeature(Language language, String name) {
  test(name, () {
    name = name.replaceAll(" ", "_");
    final languageName = "${language.runtimeType}".toLowerCase();
    final filename = "$name.text".toLowerCase();
    final inputText = File("./test/input/$languageName/$filename")
        .readAsStringSync()
        .replaceAll("\r\n", "\n");
    final expectedOutputText = File("./test/output/$languageName/$filename")
        .readAsStringSync()
        .replaceAll("\r\n", "\n");
    final timer = Stopwatch()..start();
    final spans = language.highlightText(inputText);
    timer.stop();
    print("Time: ${timer.elapsedMicroseconds} us");
    final actualOutputText = _prettyPrint(spans);
    expect(actualOutputText, expectedOutputText);
  });
}

String _prettyPrint(List<Span> spans) {
  final out = StringBuffer();

  for (final span in spans) {
    final name = span.aliases.last;

    final trimmedValue = span.value.trim();
    // Quebra de linha.
    if (trimmedValue.isEmpty) {
      // out.writeln(name);
      // out.writeln("[${span.value.length}]");
    } else {
      out.writeln(name);
      out.writeln(span.value);
    }
  }

  return out.toString();
}
