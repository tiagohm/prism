import 'dart:collection';

import 'package:prism/rule.dart';

/// Representa um conjunto de regras que compõe uma linguagem.
class Grammar extends MapBase<String, List<Rule>>
    with MapMixin<String, List<Rule>> {
  final rules = Map<String, List<Rule>>();
  final Grammar rest;

  Grammar({
    this.rest,
  });

  void combineWith(Grammar grammar) {
    grammar.rules.forEach((key, value) {
      rules[key] = value;
    });
  }

  @override
  List<Rule> operator [](Object key) {
    return rules[key];
  }

  @override
  void operator []=(String key, List<Rule> value) {
    rules[key] = value;
  }

  @override
  void clear() {
    rules.clear();
  }

  @override
  Iterable<String> get keys => rules.keys;

  @override
  List<Rule> remove(Object key) {
    return rules.remove(key);
  }
}
