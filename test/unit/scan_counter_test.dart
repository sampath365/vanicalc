import 'package:flutter_test/flutter_test.dart';
import 'package:vanicalc/features/scanner/domain/scan_counter.dart';

void main() {
  test('starts empty', () {
    final counter = ScanCounter();
    expect(counter.isEmpty, isTrue);
    expect(counter.totalItems, 0);
    expect(counter.totalAmount, 0);
  });

  test('scanning the same code increments quantity', () {
    final counter = ScanCounter()
      ..add('8901234567890')
      ..add('8901234567890')
      ..add('123456');

    expect(counter.lineCount, 2);
    expect(counter.totalItems, 3);
    expect(counter.itemFor('8901234567890')!.quantity, 2);
    expect(counter.itemFor('123456')!.quantity, 1);
  });

  test('newest item is first', () {
    final counter = ScanCounter()
      ..add('first')
      ..add('second');
    expect(counter.items.first.code, 'second');
  });

  test('price multiplies by quantity', () {
    final counter = ScanCounter()
      ..add('A', price: 25.5)
      ..add('A')
      ..add('B', price: 10);

    expect(counter.totalAmount, 61);
    expect(counter.itemFor('A')!.lineTotal, 51);
  });

  test('decrement removes an item at zero', () {
    final counter = ScanCounter()..add('A');
    counter.decrement('A');
    expect(counter.isEmpty, isTrue);
  });

  test('increment and update details', () {
    final counter = ScanCounter()..add('A');
    counter
      ..increment('A')
      ..update('A', label: 'Notebook', price: 42);

    final item = counter.itemFor('A')!;
    expect(item.quantity, 2);
    expect(item.title, 'Notebook');
    expect(counter.totalAmount, 84);
  });

  test('clear empties the counter', () {
    final counter = ScanCounter()
      ..add('A')
      ..add('B');
    counter.clear();
    expect(counter.isEmpty, isTrue);
    expect(counter.totalItems, 0);
  });

  test('blank labels fall back to the code', () {
    final counter = ScanCounter()..add('CODE', label: '  ');
    expect(counter.itemFor('CODE')!.title, 'CODE');
  });
}
