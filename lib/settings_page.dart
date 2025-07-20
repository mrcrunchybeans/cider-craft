import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';

import 'models/settings_model.dart';
import 'utils/temp_display.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Settings", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text("Use Celsius", style: TextStyle(fontSize: 18)),
                Switch(
                  value: settings.useCelsius,
                  onChanged: (bool newValue) async {
                    settings.toggleUnit(); // toggles the bool
                    await Hive.box('settings').put('useCelsius', settings.useCelsius);
                    TempDisplay.setUseFahrenheit(!settings.useCelsius); // update global formatter
                  },
                ),
                const SizedBox(width: 12),
                Text("Current Unit: ${settings.unit}", style: const TextStyle(fontSize: 18)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
