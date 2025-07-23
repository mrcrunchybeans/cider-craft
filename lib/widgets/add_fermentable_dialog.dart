import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../utils/utils.dart';

final logger = Logger();

class AddFermentableDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onAddToRecipe;
  final Function(Map<String, dynamic>) onAddToInventory;
  final Map<String, dynamic>? existing;

  const AddFermentableDialog({
    super.key,
    required this.onAddToRecipe,
    required this.onAddToInventory,
    this.existing,
  });

  @override
  State<AddFermentableDialog> createState() => _AddFermentableDialogState();
}

class _AddFermentableDialogState extends State<AddFermentableDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController ogController = TextEditingController();
  final TextEditingController phController = TextEditingController();

  String amountUnit = 'gal';
  String type = 'Juice';

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final f = widget.existing!;
      nameController.text = f['name']?.toString() ?? '';
      amountController.text = f['amount']?.toString() ?? '';
      amountUnit = f['unit']?.toString() ?? 'oz';
      type = f['type']?.toString() ?? 'Juice';
      ogController.text = f['og']?.toString() ?? '';
      phController.text = f['ph']?.toString() ?? '';
    }
  }

  Map<String, dynamic> buildFermentable() {
    final double? og = double.tryParse(ogController.text);
    final double? ph = double.tryParse(phController.text);
    return {
      'name': nameController.text,
      'amount': double.tryParse(amountController.text) ?? 0,
      'unit': amountUnit,
      'type': type,
      'og': og,
      'ph': ph,
      'acidityClass': ph != null ? CiderUtils.classifyAcidity(ph) : null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.existing != null;

    return AlertDialog(
      title: Text(isEditing ? "Edit Fermentable" : "Add Fermentable"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: amountController,
                      decoration: const InputDecoration(labelText: 'Amount'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: amountUnit,
                    onChanged: (val) => setState(() => amountUnit = val!),
                    items: ['oz', 'ml', 'gal']
                        .map((unit) => DropdownMenuItem(
                              value: unit,
                              child: Text(unit),
                            ))
                        .toList(),
                  ),
                ],
              ),
              DropdownButtonFormField<String>(
                value: type,
                onChanged: (val) => setState(() => type = val!),
                items: ['Juice', 'Fruit', 'Concentrate', 'Other']
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ))
                    .toList(),
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: ogController,
                decoration: const InputDecoration(labelText: 'Original Gravity (SG)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: phController,
                decoration: const InputDecoration(labelText: 'pH'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (val) => setState(() {}),
              ),
              if (phController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    "Acidity: ${CiderUtils.classifyAcidity(double.tryParse(phController.text) ?? 0)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        if (!isEditing)
          TextButton(
            onPressed: () {
              widget.onAddToInventory(buildFermentable());
              Navigator.of(context).pop();
            },
            child: const Text("Add to Inventory"),
          ),
        TextButton(
          onPressed: () {
            final f = buildFermentable();
            widget.onAddToRecipe(f);
            logger.i("${isEditing ? "Updated" : "Saved"} Fermentable: $f");
            Navigator.of(context).pop();
          },
          child: Text(isEditing ? "Save Changes" : "Add"),
        ),
      ],
    );
  }
}
