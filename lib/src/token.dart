import 'package:flutter/material.dart';

/// Um token armazena informações de alguma regra casada durante o highlight.
abstract class Token extends TextSpan {
  @override
  final List<Token> children;
  @override
  final String text;
  @override
  final TextStyle style;
  final int length;
  final bool greedy;

  const Token(
    this.length,
    this.greedy, {
    this.text,
    this.children,
    this.style,
  }) : super(
          text: text,
          children: children,
          style: style,
        );
}

class StringToken extends Token {
  const StringToken(String text) : super(text.length, false, text: text);
}

class RuleToken extends Token {
  const RuleToken(
    bool greedy,
    int length,
    List<Token> children,
    TextStyle style,
  ) : super(length, greedy, children: children, style: style);
}
