import 'package:flutter/material.dart';
import '../utils/utils.dart';

class Additive {
  Additive({required this.name, required this.amount, required this.unit});

  double amount;
  String name;
  String unit;
}

class AdditivesSection extends StatefulWidget {
  const AdditivesSection({
    super.key,
    required this.mustPH,
    required this.volume,
    required this.onAdd,
  });

  final double mustPH;
  final void Function(Map<String, dynamic>) onAdd;
  final double volume;

  @override
  State<AdditivesSection> createState() => _AdditivesSectionState();
}

class _AdditivesSectionState extends State<AdditivesSection> {
  List<Additive> additives = [];

  void _addAdditive() {
    final newAdditive = Additive(name: 'Custom', amount: 0, unit: 'g');
    setState(() {
      additives.add(newAdditive);
    });

    widget.onAdd({
      'name': newAdditive.name,
      'amount': newAdditive.amount,
      'unit': newAdditive.unit,
    });
  }

  Widget _buildAdditiveField(int index) {
    final additive = additives[index];

    return Row(
      children: [
        Expanded(
          child: TextFormField(
            initialValue: additive.name,
            decoration: const InputDecoration(labelText: 'Name'),
            onChanged: (value) {
              setState(() => additive.name = value);
              _updateAdditive(index);
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            initialValue: additive.amount.toString(),
            decoration: const InputDecoration(labelText: 'Amount'),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() => additive.amount = double.tryParse(value) ?? 0);
              _updateAdditive(index);
            },
          ),
        ),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: additive.unit,
          items: ['g', 'tsp', 'Campden tablets'].map((unit) {
            return DropdownMenuItem(value: unit, child: Text(unit));
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => additive.unit = value);
              _updateAdditive(index);
            }
          },
        ),
      ],
    );
  }

  void _updateAdditive(int index) {
    final additive = additives[index];
    widget.onAdd({
      'name': additive.name,
      'amount': additive.amount,
      'unit': additive.unit,
    });
  }

  @override
  Widget build(BuildContext context) {
    final ppm = CiderUtils.recommendedFreeSO2ppm(widget.mustPH);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Additives", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        ...additives.asMap().entries.map((entry) => _buildAdditiveField(entry.key)),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _addAdditive,
          child: const Text("Add Additive"),
        ),
        const SizedBox(height: 12),
        if (additives.any((a) => a.name.toLowerCase().contains('sulphite') || a.name.toLowerCase().contains('sulfite')))
          Text(
            "Recommended SO₂ dosage: ${ppm.toStringAsFixed(0)} ppm for pH ${widget.mustPH}",
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
      ],
    );
  }
}
