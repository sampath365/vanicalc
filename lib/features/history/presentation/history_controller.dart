import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app_providers.dart';
import '../domain/calculation_record.dart';

/// Reactive list of saved calculations, newest first.
class HistoryController extends Notifier<List<CalculationRecord>> {
  @override
  List<CalculationRecord> build() {
    return ref.watch(historyRepositoryProvider).all();
  }

  void refresh() {
    state = ref.read(historyRepositoryProvider).all();
  }

  Future<CalculationRecord> add({
    required String expression,
    required String result,
    required String type,
    required String languageCode,
    double? value,
  }) async {
    final record = await ref
        .read(historyRepositoryProvider)
        .add(
          expression: expression,
          result: result,
          type: type,
          languageCode: languageCode,
          value: value,
        );
    refresh();
    return record;
  }

  Future<void> delete(String id) async {
    await ref.read(historyRepositoryProvider).delete(id);
    refresh();
  }

  Future<void> clear() async {
    await ref.read(historyRepositoryProvider).clear();
    refresh();
  }

  Future<void> toggleFavorite(String id) async {
    await ref.read(historyRepositoryProvider).toggleFavorite(id);
    refresh();
  }

  List<CalculationRecord> search(String query, {bool favoritesOnly = false}) {
    return ref
        .read(historyRepositoryProvider)
        .search(query, favoritesOnly: favoritesOnly);
  }

  int get todayCount => ref.read(historyRepositoryProvider).countToday();

  int get favoriteCount => ref.read(historyRepositoryProvider).favoriteCount;
}
