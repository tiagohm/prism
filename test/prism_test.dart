import 'package:flutter_test/flutter_test.dart';
import 'package:prism/language.dart';
import 'package:prism/languages/json.dart';

void main() {
  group("Json", () {
    final json = Json(allowComments: false);
    final jsonWithComment = Json(allowComments: true);

    test('Boolean', () {
      expectBlock(json, "true\nfalse\n", [
        ["boolean", "true"],
        ["boolean", "false"],
      ]);
    });

    test('Null', () {
      expectBlock(json, "null", [
        ["null", "null"],
      ]);
    });

    test('Number', () {
      final data = json.highlight(
        "0\n123\n3.14159\n5.0e8\n0.2E+2\n47e-5\n-1.23\n-2.34E33\n-4.34E-33",
        true,
      );
      expectBlock(data[0], "number", "0");
      expectBlock(data[1], "number", "123");
      expectBlock(data[2], "number", "3.14159");
      expectBlock(data[3], "number", "5.0e8");
      expectBlock(data[4], "number", "0.2E+2");
      expectBlock(data[5], "number", "47e-5");
      expectBlock(data[6], "number", "-1.23");
      expectBlock(data[7], "number", "-2.34E33");
      expectBlock(data[8], "number", "-4.34E-33");
    });

    test('Operator & Punctuation', () {
      final data = json.highlight(":\n{}\n[]", true);
      expectBlock(data[0], "operator", ":");
      expectBlock(data[1], "punctuation", "{");
      expectBlock(data[2], "punctuation", "}");
      expectBlock(data[3], "punctuation", "[");
      expectBlock(data[4], "punctuation", "]");
    });

    test('Property', () {
      final data = json.highlight('{"foo\\"bar\\"baz":1,"foo":2}', true);
      expectBlock(data[0], "punctuation", "{");
      expectBlock(data[1], "property", '"foo\\"bar\\"baz"');
      expectBlock(data[2], "operator", ":");
      expectBlock(data[3], "number", "1");
      expectBlock(data[4], "punctuation", ",");
      expectBlock(data[5], "property", "\"foo\"");
      expectBlock(data[6], "operator", ":");
      expectBlock(data[7], "number", "2");
      expectBlock(data[8], "punctuation", "}");
    });

    test('String', () {
      final data = jsonWithComment.highlight(
          '""\n"foo"\n"foo\\"bar\\"baz"\n"/*"\n"*/"', true);
      expectBlock(data[0], "string", '""');
      expectBlock(data[1], "string", '"foo"');
      expectBlock(data[2], "string", '"foo\\"bar\\"baz"');
      expectBlock(data[3], "string", '"/*"');
      expectBlock(data[4], "string", '"*/"');
    });

    test('Comment', () {
      final data = jsonWithComment.highlight(
          '/* Block comment */\n// Line comment', true);
      expectBlock(data[0], "comment", '/* Block comment */');
      expectBlock(data[1], "comment", '// Line comment');
    });
  });
}

final HighlightMapper<List<String>> _mapper =
    (String name, String text, int start, int end) {
  return [name, text];
};

void expectBlock(
  Language language,
  String text,
  List<List<String>> expectedBlocks,
) {
  final blocks = language.highlight<List<String>>(
    text,
    ignoreWhitespaces: true,
    mapper: _mapper,
  );
  for (int i = 0; i < expectedBlocks.length; i++) {
    expect(expectedBlocks[i][0], blocks[i][0]);
    expect(expectedBlocks[i][1], blocks[i][1]);
  }
}
