/// A unit inside a conversion category.
class UnitOption {
  const UnitOption(this.name, this.symbol, this.factor);

  final String name;
  final String symbol;

  /// Multiplier to the category's base unit.
  final double factor;
}

/// A category of convertible units.
class UnitCategory {
  const UnitCategory({
    required this.key,
    required this.labelKey,
    required this.units,
    this.isTemperature = false,
  });

  final String key;
  final String labelKey;
  final List<UnitOption> units;
  final bool isTemperature;

  UnitOption unit(String symbol) =>
      units.firstWhere((unit) => unit.symbol == symbol);
}

/// Offline unit conversion across eight everyday categories.
class UnitConverter {
  const UnitConverter._();

  static const List<UnitCategory> categories = <UnitCategory>[
    UnitCategory(
      key: 'length',
      labelKey: 'converter_length',
      units: [
        UnitOption('Metre', 'm', 1),
        UnitOption('Kilometre', 'km', 1000),
        UnitOption('Centimetre', 'cm', 0.01),
        UnitOption('Millimetre', 'mm', 0.001),
        UnitOption('Inch', 'in', 0.0254),
        UnitOption('Foot', 'ft', 0.3048),
        UnitOption('Yard', 'yd', 0.9144),
        UnitOption('Mile', 'mi', 1609.344),
      ],
    ),
    UnitCategory(
      key: 'weight',
      labelKey: 'converter_weight',
      units: [
        UnitOption('Kilogram', 'kg', 1),
        UnitOption('Gram', 'g', 0.001),
        UnitOption('Milligram', 'mg', 0.000001),
        UnitOption('Tonne', 't', 1000),
        UnitOption('Pound', 'lb', 0.45359237),
        UnitOption('Ounce', 'oz', 0.028349523125),
      ],
    ),
    UnitCategory(
      key: 'temperature',
      labelKey: 'converter_temperature',
      isTemperature: true,
      units: [
        UnitOption('Celsius', '°C', 1),
        UnitOption('Fahrenheit', '°F', 1),
        UnitOption('Kelvin', 'K', 1),
      ],
    ),
    UnitCategory(
      key: 'area',
      labelKey: 'converter_area',
      units: [
        UnitOption('Square metre', 'm²', 1),
        UnitOption('Square kilometre', 'km²', 1000000),
        UnitOption('Square foot', 'ft²', 0.09290304),
        UnitOption('Square yard', 'yd²', 0.83612736),
        UnitOption('Acre', 'acre', 4046.8564224),
        UnitOption('Hectare', 'ha', 10000),
      ],
    ),
    UnitCategory(
      key: 'volume',
      labelKey: 'converter_volume',
      units: [
        UnitOption('Litre', 'L', 1),
        UnitOption('Millilitre', 'mL', 0.001),
        UnitOption('Cubic metre', 'm³', 1000),
        UnitOption('Gallon (US)', 'gal', 3.785411784),
        UnitOption('Pint (US)', 'pt', 0.473176473),
      ],
    ),
    UnitCategory(
      key: 'speed',
      labelKey: 'converter_speed',
      units: [
        UnitOption('Metre/second', 'm/s', 1),
        UnitOption('Kilometre/hour', 'km/h', 0.2777777778),
        UnitOption('Mile/hour', 'mph', 0.44704),
        UnitOption('Knot', 'kn', 0.5144444444),
      ],
    ),
    UnitCategory(
      key: 'time',
      labelKey: 'converter_time',
      units: [
        UnitOption('Second', 's', 1),
        UnitOption('Minute', 'min', 60),
        UnitOption('Hour', 'h', 3600),
        UnitOption('Day', 'd', 86400),
        UnitOption('Week', 'wk', 604800),
      ],
    ),
    UnitCategory(
      key: 'data',
      labelKey: 'converter_data',
      units: [
        UnitOption('Byte', 'B', 1),
        UnitOption('Kilobyte', 'KB', 1024),
        UnitOption('Megabyte', 'MB', 1048576),
        UnitOption('Gigabyte', 'GB', 1073741824),
        UnitOption('Terabyte', 'TB', 1099511627776),
      ],
    ),
  ];

  static double convert({
    required UnitCategory category,
    required UnitOption from,
    required UnitOption to,
    required double value,
  }) {
    if (category.isTemperature) {
      final celsius = _toCelsius(from.symbol, value);
      return _fromCelsius(to.symbol, celsius);
    }
    return value * from.factor / to.factor;
  }

  static double _toCelsius(String symbol, double value) {
    switch (symbol) {
      case '°F':
        return (value - 32) * 5 / 9;
      case 'K':
        return value - 273.15;
      default:
        return value;
    }
  }

  static double _fromCelsius(String symbol, double celsius) {
    switch (symbol) {
      case '°F':
        return celsius * 9 / 5 + 32;
      case 'K':
        return celsius + 273.15;
      default:
        return celsius;
    }
  }
}
