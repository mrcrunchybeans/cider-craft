import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'widgets/add_fermentable_dialog.dart';
import 'widgets/additives_section.dart';
import 'utils/utils.dart';

final logger = Logger();

class RecipeBuilderPage extends StatefulWidget {
  const RecipeBuilderPage({super.key});

  @override
  State<RecipeBuilderPage> createState() => _RecipeBuilderPageState();
}

class _RecipeBuilderPageState extends State<RecipeBuilderPage> {
  List<Map<String, dynamic>> fermentables = [];
  List<Map<String, dynamic>> additives = [];

  double og = 1.050;
  double fg = 1.010;
  double abv = 0.0;
  bool showAdvanced = false;
  String recipeName = '';

  @override
  void initState() {
    super.initState();
    calculateStats();
  }

  void calculateStats() {
    fg = CiderUtils.estimateFG(); // Your simplified estimate
    abv = CiderUtils.calculateABV(og, fg);
    setState(() {});
    logger.i('Recalculated stats: OG=$og, FG=$fg, ABV=$abv');
  }

  void addFermentable(Map<String, dynamic> f) {
    setState(() {
      fermentables.add(f);
      if (f.containsKey('og') && f['og'] != null) {
        og = f['og'];
      }
    });
    calculateStats();
    logger.d("Added fermentable: ${f['name']}");
  }

  void editFermentable(int index) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => AddFermentableDialog(
        onAddToRecipe: (_) {},
        onAddToInventory: (_) {},
        existing: fermentables[index],
      ),
    );
    if (result != null) {
      setState(() {
        fermentables[index] = result;
      });
      calculateStats();
    }
  }

  void addAdditive(Map<String, dynamic> a) {
    setState(() {
      additives.add(a);
    });
    logger.d("Added additive: ${a['name']}");
  }

  void saveRecipe() {
    showDialog(
      context: context,
      builder: (_) {
        final nameController = TextEditingController();
        return AlertDialog(
          title: const Text("Save Recipe"),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: "Recipe Name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                recipeName = nameController.text;
                logger.i("Recipe '$recipeName' saved");
                Navigator.of(context).pop();
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cider Recipe Builder"),
        actions: [
          IconButton(onPressed: saveRecipe, icon: const Icon(Icons.save)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Row(
            children: [
              const Text("Show Advanced Fields"),
              Switch(
                value: showAdvanced,
                onChanged: (val) => setState(() => showAdvanced = val),
              )
            ],
          ),
          const SizedBox(height: 12),
          _buildSectionTitle("Fermentables", onAdd: () async {
            final result = await showDialog<Map<String, dynamic>>(
              context: context,
              builder: (_) => AddFermentableDialog(
                onAddToRecipe: addFermentable,
                onAddToInventory: (_) {},
              ),
            );
            if (result != null) addFermentable(result);
          }),
          ...fermentables.asMap().entries.map((entry) {
            final i = entry.key;
            final f = entry.value;
            return ListTile(
              title: Text(f['name'] ?? 'Unnamed'),
              subtitle: Text("${f['amount_lb']} lb, OG: ${f['og']?.toStringAsFixed(3) ?? '—'}"),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => editFermentable(i),
              ),
            );
          }),
          const SizedBox(height: 24),
          _buildSectionTitle("Additives", onAdd: () async {
            final result = await showDialog<Map<String, dynamic>>(
              context: context,
              builder: (_) => AdditivesSection(
                mustPH: 3.4,
                volume: 5.0,
                onAdd: addAdditive,
              ),
            );
            if (result != null) addAdditive(result);
          }),
          ...additives.map((a) => ListTile(
                title: Text(a['name']),
                subtitle: Text("${a['amount']} ${a['unit']}"),
              )),
          const SizedBox(height: 24),
          _buildSectionTitle("Fermentation Profile"),
          ListTile(
            title: const Text("Original Gravity"),
            subtitle: Text(og.toStringAsFixed(3)),
          ),
          ListTile(
            title: const Text("Final Gravity"),
            subtitle: Text(fg.toStringAsFixed(3)),
          ),
          ListTile(
            title: const Text("ABV"),
            subtitle: Text("${abv.toStringAsFixed(2)}%"),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {VoidCallback? onAdd}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        if (onAdd != null)
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: Text("Add ${title.split(' ').first}"),
          ),
      ],
    );
  }
}
