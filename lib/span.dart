class Span {
  final String value;
  final Set<String> aliases;

  Span({
    this.value,
    this.aliases,
  });

  @override
  String toString() {
    return "Span {value:$value aliases:$aliases}";
  }
}
