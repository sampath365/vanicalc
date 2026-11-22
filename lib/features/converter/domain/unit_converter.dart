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
        UnitOption('Nautical mile', 'nmi', 1852),
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
        UnitOption('Stone', 'st', 6.35029318),
        UnitOption('Carat', 'ct', 0.0002),
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
        UnitOption('Square inch', 'in²', 0.00064516),
        UnitOption('Square mile', 'mi²', 2589988.110336),
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
        UnitOption('Cup (US)', 'cup', 0.2365882365),
        UnitOption('Tablespoon', 'tbsp', 0.01478676478125),
        UnitOption('Teaspoon', 'tsp', 0.00492892159375),
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
        UnitOption('Millisecond', 'ms', 0.001),
        UnitOption('Year', 'yr', 31557600),
      ],
    ),
    UnitCategory(
      key: 'pressure',
      labelKey: 'converter_pressure',
      units: [
        UnitOption('Pascal', 'Pa', 1),
        UnitOption('Kilopascal', 'kPa', 1000),
        UnitOption('Bar', 'bar', 100000),
        UnitOption('PSI', 'psi', 6894.757293168),
        UnitOption('Atmosphere', 'atm', 101325),
        UnitOption('mmHg', 'mmHg', 133.322387415),
      ],
    ),
    UnitCategory(
      key: 'energy',
      labelKey: 'converter_energy',
      units: [
        UnitOption('Joule', 'J', 1),
        UnitOption('Kilojoule', 'kJ', 1000),
        UnitOption('Calorie', 'cal', 4.184),
        UnitOption('Kilocalorie', 'kcal', 4184),
        UnitOption('Watt-hour', 'Wh', 3600),
        UnitOption('Kilowatt-hour', 'kWh', 3600000),
        UnitOption('BTU', 'BTU', 1055.05585262),
      ],
    ),
    UnitCategory(
      key: 'power',
      labelKey: 'converter_power',
      units: [
        UnitOption('Watt', 'W', 1),
        UnitOption('Kilowatt', 'kW', 1000),
        UnitOption('Megawatt', 'MW', 1000000),
        UnitOption('Horsepower', 'hp', 745.699871582),
        UnitOption('BTU/hour', 'BTU/h', 0.29307107017),
      ],
    ),
    UnitCategory(
      key: 'angle',
      labelKey: 'converter_angle',
      units: [
        UnitOption('Degree', '°', 1),
        UnitOption('Radian', 'rad', 57.29577951308232),
        UnitOption('Gradian', 'grad', 0.9),
        UnitOption('Turn', 'turn', 360),
        UnitOption('Arcminute', 'arcmin', 1 / 60),
        UnitOption('Arcsecond', 'arcsec', 1 / 3600),
      ],
    ),
    UnitCategory(
      key: 'frequency',
      labelKey: 'converter_frequency',
      units: [
        UnitOption('Hertz', 'Hz', 1),
        UnitOption('Kilohertz', 'kHz', 1000),
        UnitOption('Megahertz', 'MHz', 1000000),
        UnitOption('Gigahertz', 'GHz', 1000000000),
        UnitOption('RPM', 'rpm', 1 / 60),
      ],
    ),
    UnitCategory(
      key: 'force',
      labelKey: 'converter_force',
      units: [
        UnitOption('Newton', 'N', 1),
        UnitOption('Kilonewton', 'kN', 1000),
        UnitOption('Kilogram-force', 'kgf', 9.80665),
        UnitOption('Pound-force', 'lbf', 4.4482216152605),
        UnitOption('Dyne', 'dyn', 0.00001),
      ],
    ),
    UnitCategory(
      key: 'torque',
      labelKey: 'converter_torque',
      units: [
        UnitOption('Newton metre', 'N·m', 1),
        UnitOption('Kilogram-force metre', 'kgf·m', 9.80665),
        UnitOption('Pound-force foot', 'lbf·ft', 1.3558179483314),
        UnitOption('Pound-force inch', 'lbf·in', 0.11298482902762),
      ],
    ),
    UnitCategory(
      key: 'acceleration',
      labelKey: 'converter_acceleration',
      units: [
        UnitOption('Metre/second²', 'm/s²', 1),
        UnitOption('Standard gravity', 'g', 9.80665),
        UnitOption('Foot/second²', 'ft/s²', 0.3048),
      ],
    ),
    UnitCategory(
      key: 'density',
      labelKey: 'converter_density',
      units: [
        UnitOption('Kilogram/metre³', 'kg/m³', 1),
        UnitOption('Gram/cm³', 'g/cm³', 1000),
        UnitOption('Kilogram/litre', 'kg/L', 1000),
        UnitOption('Pound/foot³', 'lb/ft³', 16.01846337396),
      ],
    ),
    UnitCategory(
      key: 'flow',
      labelKey: 'converter_flow',
      units: [
        UnitOption('Metre³/second', 'm³/s', 1),
        UnitOption('Litre/second', 'L/s', 0.001),
        UnitOption('Litre/minute', 'L/min', 0.0000166666667),
        UnitOption('Metre³/hour', 'm³/h', 0.000277777778),
        UnitOption('Gallon/minute', 'gal/min', 0.0000630901964),
      ],
    ),
    UnitCategory(
      key: 'illuminance',
      labelKey: 'converter_illuminance',
      units: [
        UnitOption('Lux', 'lx', 1),
        UnitOption('Foot-candle', 'fc', 10.7639104167),
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
        UnitOption('Petabyte', 'PB', 1125899906842624),
        UnitOption('Bit', 'bit', 0.125),
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
