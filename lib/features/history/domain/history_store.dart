import 'calculation_record.dart';

/// Storage contract for calculation history, allowing the UI to run against
/// Hive in production and an in-memory store in tests.
abstract interface class HistoryStore {
  List<CalculationRecord> all();

  List<CalculationRecord> search(String query, {bool favoritesOnly = false});

  Future<CalculationRecord> add({
    required String expression,
    required String result,
    required String type,
    required String languageCode,
    double? value,
    DateTime? createdAt,
  });

  Future<void> delete(String id);

  Future<void> clear();

  Future<CalculationRecord?> toggleFavorite(String id);

  int countToday({DateTime? now});

  int get favoriteCount;
}
