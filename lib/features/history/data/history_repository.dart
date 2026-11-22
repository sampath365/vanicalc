import 'package:hive/hive.dart';

import '../domain/calculation_record.dart';
import '../domain/history_store.dart';

/// Hive-backed calculation history with search, favourites and statistics.
class HistoryRepository implements HistoryStore {
  HistoryRepository(this._box);

  final Box<dynamic> _box;

  static const String boxName = 'calculation_history';
  static const int maxRecords = 500;

  @override
  List<CalculationRecord> all() {
    final records = <CalculationRecord>[];
    for (final value in _box.values) {
      if (value is Map) {
        final record = CalculationRecord.fromMap(value);
        if (record != null) records.add(record);
      }
    }
    records.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return records;
  }

  @override
  List<CalculationRecord> search(String query, {bool favoritesOnly = false}) {
    final normalized = query.trim().toLowerCase();
    return all().where((record) {
      if (favoritesOnly && !record.favorite) return false;
      if (normalized.isEmpty) return true;
      return record.expression.toLowerCase().contains(normalized) ||
          record.result.toLowerCase().contains(normalized);
    }).toList(growable: false);
  }

  @override
  Future<CalculationRecord> add({
    required String expression,
    required String result,
    required String type,
    required String languageCode,
    double? value,
    DateTime? createdAt,
  }) async {
    final now = createdAt ?? DateTime.now();
    final record = CalculationRecord(
      id: '${now.microsecondsSinceEpoch}-${_box.length}',
      expression: expression,
      result: result,
      value: value,
      type: type,
      languageCode: languageCode,
      createdAt: now,
    );
    await _box.put(record.id, record.toMap());
    await _prune();
    return record;
  }

  @override
  Future<void> delete(String id) => _box.delete(id);

  @override
  Future<void> clear() => _box.clear();

  @override
  Future<CalculationRecord?> toggleFavorite(String id) async {
    final raw = _box.get(id);
    if (raw is! Map) return null;
    final record = CalculationRecord.fromMap(raw);
    if (record == null) return null;
    final updated = record.copyWith(favorite: !record.favorite);
    await _box.put(id, updated.toMap());
    return updated;
  }

  @override
  int countToday({DateTime? now}) {
    final reference = now ?? DateTime.now();
    return all().where((record) {
      return record.createdAt.year == reference.year &&
          record.createdAt.month == reference.month &&
          record.createdAt.day == reference.day;
    }).length;
  }

  @override
  int get favoriteCount => all().where((record) => record.favorite).length;

  Future<void> _prune() async {
    if (_box.length <= maxRecords) return;
    final records = all();
    final overflow = records.skip(maxRecords).toList();
    for (final record in overflow) {
      await _box.delete(record.id);
    }
  }
}
