import 'package:flutter/material.dart';

class AddAdditiveDialog extends StatefulWidget {
  const AddAdditiveDialog({super.key});

  @override
  State<AddAdditiveDialog> createState() => _AddAdditiveDialogState();
}

class _AddAdditiveDialogState extends State<AddAdditiveDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  String unit = 'g';

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final additive = {
        'name': nameController.text.trim(),
        'amount': double.tryParse(amountController.text.trim()) ?? 0.0,
        'unit': unit,
      };
      Navigator.of(context).pop(additive); // Return to parent
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Additive'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (val) => val == null || val.isEmpty ? 'Enter name' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: amountController,
                    decoration: const InputDecoration(labelText: 'Amount'),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    validator: (val) => double.tryParse(val ?? '') == null ? 'Enter number' : null,
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: unit,
                  onChanged: (val) => setState(() => unit = val ?? 'g'),
                  items: ['g', 'mg', 'tsp', 'tablet']
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                )
              ],
            )
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
