class TempDisplay {
  static bool _useFahrenheit = false;

  static void setUseFahrenheit(bool useF) {
    _useFahrenheit = useF;
  }

  static String format(double tempC) {
    if (_useFahrenheit) {
      final f = (tempC * 9 / 5) + 32;
      return "${f.toStringAsFixed(1)}°F";
    }
    return "${tempC.toStringAsFixed(1)}°C";
  }

  static double convertToCelsius(double input, String unit) {
    return unit == "°F" ? (input - 32) * 5 / 9 : input;
  }

  static bool get isF => _useFahrenheit;
}
