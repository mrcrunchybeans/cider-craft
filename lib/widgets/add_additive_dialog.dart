// lib/widgets/add_additive_dialog.dart

import 'package:flutter/material.dart';

class AddAdditiveDialog extends StatefulWidget {
  const AddAdditiveDialog({super.key});

  @override
  State<AddAdditiveDialog> createState() => _AddAdditiveDialogState();
}

class _AddAdditiveDialogState extends State<AddAdditiveDialog> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  String unit = 'g';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Additive'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: amountController,
            decoration: const InputDecoration(labelText: 'Amount'),
            keyboardType: TextInputType.number,
          ),
          DropdownButton<String>(
            value: unit,
            onChanged: (value) {
              if (value != null) {
                setState(() => unit = value);
              }
            },
            items: ['g', 'tsp', 'Campden tablets'].map((u) {
              return DropdownMenuItem(value: u, child: Text(u));
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Cancel
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final name = nameController.text;
            final amount = double.tryParse(amountController.text) ?? 0;

            Navigator.of(context).pop({
              'name': name,
              'amount': amount,
              'unit': unit,
            });
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
