import 'package:flutter_test/flutter_test.dart';
import 'package:prism/flutter_prism.dart';
import 'package:prism/languages/json.dart';
import 'package:prism/languages/markup.dart';

import 'utils.dart';

void main() {
  // https://github.com/PrismJS/prism/tree/master/tests/languages

  final json = Json();
  final jsonWithComments = Json(allowComments: true);
  final markup = Markup();

  group('Json', () {
    testFeature(json, "Boolean");
    testFeature(jsonWithComments, "Comment");
    testFeature(json, "Number");
  });

  group('Markup', () {
    testFeature(markup, "Tag");
    testFeature(markup, "Tag Attribute");
  });
}
