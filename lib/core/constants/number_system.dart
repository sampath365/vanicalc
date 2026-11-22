/// Numbering conventions used by the number-to-words engine.
enum NumberSystem {
  indian('indian'),
  international('international');

  const NumberSystem(this.key);

  final String key;

  static NumberSystem fromKey(String? key) {
    return NumberSystem.values.firstWhere(
      (value) => value.key == key,
      orElse: () => NumberSystem.indian,
    );
  }
}
