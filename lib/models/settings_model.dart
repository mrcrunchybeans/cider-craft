// models/settings_model.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../utils/temp_display.dart';

class SettingsModel extends ChangeNotifier {
  bool _useCelsius = true;

  bool get useCelsius => _useCelsius;

  String get unit => _useCelsius ? "°C" : "°F";

  Future<void> toggleUnit() async {
    _useCelsius = !_useCelsius;

    // Save to Hive
    final box = Hive.box('settings');
    await box.put('useCelsius', _useCelsius);

    // Update temp display logic
    TempDisplay.setUseFahrenheit(!_useCelsius);

    notifyListeners();
  }

  void setUnitFromStorage(bool useCelsius) {
    _useCelsius = useCelsius;
    TempDisplay.setUseFahrenheit(!useCelsius);
  }
}
