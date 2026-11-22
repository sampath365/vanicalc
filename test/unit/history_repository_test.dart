import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:vanicalc/features/history/data/history_repository.dart';
import 'package:vanicalc/features/history/domain/calculation_record.dart';

void main() {
  late Directory directory;
  late Box<dynamic> box;
  late HistoryRepository repository;

  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('vanicalc_history_');
    Hive.init(directory.path);
  });

  setUp(() async {
    box = await Hive.openBox<dynamic>(
      'history_${DateTime.now().microsecondsSinceEpoch}',
    );
    repository = HistoryRepository(box);
  });

  tearDown(() async {
    if (box.isOpen) await box.close();
  });

  Future<CalculationRecord> add({
    String expression = '2+2',
    String result = '4',
    String type = CalculationType.standard,
    String language = 'en',
    DateTime? createdAt,
  }) {
    return repository.add(
      expression: expression,
      result: result,
      type: type,
      languageCode: language,
      value: double.tryParse(result),
      createdAt: createdAt,
    );
  }

  test('starts empty', () {
    expect(repository.all(), isEmpty);
    expect(repository.favoriteCount, 0);
  });

  test('saves and reads a record', () async {
    await add();
    final records = repository.all();
    expect(records, hasLength(1));
    expect(records.first.expression, '2+2');
    expect(records.first.result, '4');
    expect(records.first.type, CalculationType.standard);
    expect(records.first.languageCode, 'en');
    expect(records.first.favorite, isFalse);
  });

  test('returns newest first', () async {
    await add(expression: '1+1', result: '2', createdAt: DateTime(2024, 1, 1));
    await add(expression: '2+2', result: '4', createdAt: DateTime(2024, 2, 1));
    await add(expression: '3+3', result: '6', createdAt: DateTime(2024, 3, 1));
    final records = repository.all();
    expect(records.map((record) => record.expression), ['3+3', '2+2', '1+1']);
  });

  test('searches expression and result', () async {
    await add(expression: '25+35', result: '60');
    await add(expression: '10*4', result: '40');
    expect(repository.search('25'), hasLength(1));
    expect(repository.search('40'), hasLength(1));
    expect(repository.search('nothing'), isEmpty);
    expect(repository.search(''), hasLength(2));
  });

  test('filters favourites', () async {
    final first = await add(expression: '1+1', result: '2');
    await add(expression: '2+2', result: '4');
    await repository.toggleFavorite(first.id);
    expect(repository.favoriteCount, 1);
    expect(repository.search('', favoritesOnly: true), hasLength(1));
    expect(repository.search('', favoritesOnly: true).first.id, first.id);
  });

  test('toggles favourites back off', () async {
    final record = await add();
    await repository.toggleFavorite(record.id);
    expect(repository.favoriteCount, 1);
    await repository.toggleFavorite(record.id);
    expect(repository.favoriteCount, 0);
  });

  test('deletes a single record', () async {
    final first = await add(expression: '1+1');
    await add(expression: '2+2');
    await repository.delete(first.id);
    expect(repository.all(), hasLength(1));
    expect(repository.all().first.expression, '2+2');
  });

  test('clears all records', () async {
    await add();
    await add(expression: '3+3');
    await repository.clear();
    expect(repository.all(), isEmpty);
  });

  test('counts calculations made today', () async {
    final now = DateTime.now();
    await add(createdAt: now);
    await add(expression: '3+3', createdAt: now);
    await add(
      expression: 'old',
      createdAt: now.subtract(const Duration(days: 3)),
    );
    expect(repository.countToday(now: now), 2);
  });

  test('caps the history at 500 records', () async {
    for (var index = 0; index < 505; index++) {
      await add(
        expression: '1+$index',
        result: '${1 + index}',
        createdAt: DateTime(2024, 1, 1).add(Duration(minutes: index)),
      );
    }
    final records = repository.all();
    expect(records, hasLength(HistoryRepository.maxRecords));
    expect(records.first.expression, '1+504');
  });

  test('survives corrupt entries', () async {
    await box.put('broken', {'id': 'broken'});
    expect(repository.all(), isEmpty);
  });
}
