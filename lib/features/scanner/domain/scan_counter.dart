/// A single scanned line in the counter.
class ScannedItem {
  const ScannedItem({
    required this.code,
    required this.quantity,
    this.label,
    this.price,
  });

  final String code;
  final int quantity;
  final String? label;
  final double? price;

  double get lineTotal => (price ?? 0) * quantity;

  String get title {
    final name = label?.trim();
    return name == null || name.isEmpty ? code : name;
  }

  ScannedItem copyWith({
    String? code,
    int? quantity,
    String? label,
    double? price,
    bool clearPrice = false,
  }) {
    return ScannedItem(
      code: code ?? this.code,
      quantity: quantity ?? this.quantity,
      label: label ?? this.label,
      price: clearPrice ? null : (price ?? this.price),
    );
  }
}

/// Pure scan-and-count model: scanning the same code increments its quantity.
class ScanCounter {
  ScanCounter([List<ScannedItem>? items])
    : _items = List<ScannedItem>.from(items ?? const []);

  final List<ScannedItem> _items;

  List<ScannedItem> get items => List.unmodifiable(_items);

  bool get isEmpty => _items.isEmpty;

  int get lineCount => _items.length;

  int get totalItems =>
      _items.fold<int>(0, (total, item) => total + item.quantity);

  double get totalAmount =>
      _items.fold<double>(0, (total, item) => total + item.lineTotal);

  ScannedItem? itemFor(String code) {
    for (final item in _items) {
      if (item.code == code) return item;
    }
    return null;
  }

  /// Adds a code or increments an existing one. Returns the updated item.
  ScannedItem add(String code, {String? label, double? price}) {
    final normalized = code.trim();
    final index = _items.indexWhere((item) => item.code == normalized);
    if (index == -1) {
      final item = ScannedItem(
        code: normalized,
        quantity: 1,
        label: label,
        price: price,
      );
      _items.insert(0, item);
      return item;
    }
    final updated = _items[index].copyWith(
      quantity: _items[index].quantity + 1,
      label: label ?? _items[index].label,
      price: price ?? _items[index].price,
    );
    _items[index] = updated;
    return updated;
  }

  void increment(String code) {
    final index = _items.indexWhere((item) => item.code == code);
    if (index == -1) return;
    _items[index] = _items[index].copyWith(
      quantity: _items[index].quantity + 1,
    );
  }

  void decrement(String code) {
    final index = _items.indexWhere((item) => item.code == code);
    if (index == -1) return;
    final next = _items[index].quantity - 1;
    if (next <= 0) {
      _items.removeAt(index);
    } else {
      _items[index] = _items[index].copyWith(quantity: next);
    }
  }

  void update(
    String code, {
    String? label,
    double? price,
    bool clearPrice = false,
  }) {
    final index = _items.indexWhere((item) => item.code == code);
    if (index == -1) return;
    _items[index] = _items[index].copyWith(
      label: label,
      price: price,
      clearPrice: clearPrice,
    );
  }

  void remove(String code) {
    _items.removeWhere((item) => item.code == code);
  }

  void clear() => _items.clear();
}
