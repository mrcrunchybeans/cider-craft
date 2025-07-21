import 'package:flutter/material.dart';

class AddYeastDialog extends StatefulWidget {
  final void Function(Map<String, dynamic>) onAdd;
  final Map<String, dynamic>? existing;

  const AddYeastDialog({
    super.key,
    required this.onAdd,
    this.existing,
  });

  @override
  State<AddYeastDialog> createState() => _AddYeastDialogState();
}

class _AddYeastDialogState extends State<AddYeastDialog> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final amountController = TextEditingController();

  String unit = "g";

  final List<String> unitOptions = ["g", "packets"];

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      nameController.text = widget.existing!['name'] ?? '';
      amountController.text = widget.existing!['amount']?.toString() ?? '';
      unit = widget.existing!['unit'] ?? 'g';
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onAdd({
        'name': nameController.text.trim(),
        'amount': double.tryParse(amountController.text) ?? 0.0,
        'unit': unit,
      });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing != null ? "Edit Yeast" : "Add Yeast"),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Yeast Name"),
              validator: (val) =>
                  val == null || val.trim().isEmpty ? "Enter yeast name" : null,
            ),
            TextFormField(
              controller: amountController,
              decoration: const InputDecoration(labelText: "Amount"),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (val) =>
                  val == null || val.isEmpty ? "Enter amount" : null,
            ),
            DropdownButtonFormField<String>(
              value: unit,
              items: unitOptions
                  .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                  .toList(),
              onChanged: (val) => setState(() => unit = val ?? "g"),
              decoration: const InputDecoration(labelText: "Unit"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text("Save"),
        ),
      ],
    );
  }
}
