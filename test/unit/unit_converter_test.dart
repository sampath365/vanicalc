import 'package:flutter_test/flutter_test.dart';
import 'package:vanicalc/features/converter/domain/unit_converter.dart';

void main() {
  UnitCategory category(String key) =>
      UnitConverter.categories.firstWhere((item) => item.key == key);

  double convert(String categoryKey, String from, String to, double value) {
    final item = category(categoryKey);
    return UnitConverter.convert(
      category: item,
      from: item.unit(from),
      to: item.unit(to),
      value: value,
    );
  }

  group('length', () {
    test('kilometre to metre', () => expect(convert('length', 'km', 'm', 1), 1000));
    test('metre to centimetre', () => expect(convert('length', 'm', 'cm', 2), 200));
    test('inch to centimetre', () {
      expect(convert('length', 'in', 'cm', 1), closeTo(2.54, 1e-9));
    });
    test('mile to kilometre', () {
      expect(convert('length', 'mi', 'km', 1), closeTo(1.609344, 1e-9));
    });
    test('foot to metre', () {
      expect(convert('length', 'ft', 'm', 3), closeTo(0.9144, 1e-9));
    });
  });

  group('weight', () {
    test('kilogram to gram', () => expect(convert('weight', 'kg', 'g', 2), 2000));
    test('pound to kilogram', () {
      expect(convert('weight', 'lb', 'kg', 1), closeTo(0.45359237, 1e-9));
    });
  });

  group('temperature', () {
    test('celsius to fahrenheit', () {
      expect(convert('temperature', '°C', '°F', 0), closeTo(32, 1e-9));
      expect(convert('temperature', '°C', '°F', 100), closeTo(212, 1e-9));
    });
    test('fahrenheit to celsius', () {
      expect(convert('temperature', '°F', '°C', 212), closeTo(100, 1e-9));
    });
    test('celsius to kelvin', () {
      expect(convert('temperature', '°C', 'K', 0), closeTo(273.15, 1e-9));
    });
    test('kelvin to celsius', () {
      expect(convert('temperature', 'K', '°C', 300), closeTo(26.85, 1e-9));
    });
  });

  group('data', () {
    test('gigabyte to megabyte', () {
      expect(convert('data', 'GB', 'MB', 1), 1024);
    });
    test('byte to kilobyte', () {
      expect(convert('data', 'B', 'KB', 2048), 2);
    });
  });

  group('other categories', () {
    test('acre to square metre', () {
      expect(convert('area', 'acre', 'm²', 1), closeTo(4046.8564224, 1e-6));
    });
    test('litre to millilitre', () {
      expect(convert('volume', 'L', 'mL', 1.5), closeTo(1500, 1e-9));
    });
    test('kilometre per hour to metre per second', () {
      expect(convert('speed', 'km/h', 'm/s', 36), closeTo(10, 1e-6));
    });
    test('hour to minute', () {
      expect(convert('time', 'h', 'min', 2), 120);
    });
  });

  test('every category has at least two units', () {
    for (final item in UnitConverter.categories) {
      expect(item.units.length, greaterThanOrEqualTo(2));
    }
  });
}
