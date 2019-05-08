import 'package:flutter_test/flutter_test.dart';
import 'package:prism/languages/markup.dart';

import 'utils.dart';

void main() {
  final markup = Markup();

  group('Markup', () {
    testFeature(markup, "Tag");
  });
}
