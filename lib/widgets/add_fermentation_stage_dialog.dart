import 'package:flutter/material.dart';
import '../utils/temp_display.dart';

class AddFermentationStageDialog extends StatefulWidget {
  final Map<String, dynamic>? existing;
  final Function(Map<String, dynamic>) onSave;

  const AddFermentationStageDialog({
    super.key,
    this.existing,
    required this.onSave,
  });

  @override
  State<AddFermentationStageDialog> createState() => _AddFermentationStageDialogState();
}

class _AddFermentationStageDialogState extends State<AddFermentationStageDialog> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController tempController = TextEditingController();
  final TextEditingController daysController = TextEditingController();
  String tempUnit = TempDisplay.isF ? '°F' : '°C';

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final e = widget.existing!;
      nameController.text = e['name'] ?? '';
      double tempC = e['temp'] ?? 0.0;
      double displayTemp = tempUnit == '°F' ? (tempC * 9 / 5) + 32 : tempC;
      tempController.text = displayTemp.toStringAsFixed(1);
      daysController.text = e['days']?.toString() ?? '';
    }
  }

  void saveStage() {
    double inputTemp = double.tryParse(tempController.text) ?? 0.0;
    double tempC = TempDisplay.convertToCelsius(inputTemp, tempUnit);

    final stage = {
      'name': nameController.text.trim(),
      'temp': tempC, // Always store in Celsius
      'days': int.tryParse(daysController.text) ?? 0,
    };

    widget.onSave(stage);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Fermentation Stage"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Stage Name'),
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: tempController,
                    decoration: const InputDecoration(labelText: 'Temperature'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: tempUnit,
                  onChanged: (val) => setState(() => tempUnit = val!),
                  items: ['°C', '°F']
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                ),
              ],
            ),
            TextFormField(
              controller: daysController,
              decoration: const InputDecoration(labelText: 'Days'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: saveStage,
          child: const Text("Save"),
        ),
      ],
    );
  }
}
