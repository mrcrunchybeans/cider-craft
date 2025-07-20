
import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/temp_display.dart';
import 'package:logger/logger.dart';
import 'package:hive/hive.dart';
import 'widgets/add_additive_dialog.dart';
import 'widgets/add_fermentation_stage_dialog.dart';
import 'widgets/add_fermentable_dialog.dart';
import 'utils/utils.dart';
import 'models/recipe_model.dart';
import 'recipe_list_page.dart';

final logger = Logger();

class RecipeBuilderPage extends StatefulWidget {
  final RecipeModel? existingRecipe;
  final int? recipeKey;
  final bool isClone;

  const RecipeBuilderPage({
    super.key,
    this.existingRecipe,
    this.recipeKey,
    this.isClone = false,
  });

  @override
  State<RecipeBuilderPage> createState() => _RecipeBuilderPageState();
}

class _RecipeBuilderPageState extends State<RecipeBuilderPage> {
  double abv = 0.0;
  List<Map<String, dynamic>> additives = [];
  List<Map<String, dynamic>> fermentables = [];
  List<Map<String, dynamic>> fermentationStages = [];
  double fg = 1.010;
  double og = 1.050;
  bool showAdvanced = false;

  @override
void initState() {
  super.initState();
  if (widget.existingRecipe != null) {
    final recipe = widget.existingRecipe!;
    additives = List<Map<String, dynamic>>.from(recipe.additives);
    fermentables = List<Map<String, dynamic>>.from(recipe.fermentables);
    fermentationStages = List<Map<String, dynamic>>.from(recipe.fermentationStages);
    og = recipe.og;
    fg = recipe.fg;
    abv = recipe.abv;
  }
  calculateStats();
}


  void calculateStats() {
    fg = CiderUtils.estimateFG();
    abv = CiderUtils.calculateABV(og, fg);
    setState(() {});
    logger.i('Recalculated stats: OG=\$og, FG=\$fg, ABV=\$abv');
  }

  void addFermentable(Map<String, dynamic> f) {
    setState(() {
      fermentables.add(f);
      if (f.containsKey('og') && f['og'] != null) {
        og = f['og'];
      }
    });
    calculateStats();
    logger.d("Added fermentable: \${f['name']}");
  }

  void editFermentable(int index) async {
  final existing = fermentables[index];

  await showDialog<Map<String, dynamic>>(
    context: context,
    builder: (_) => AddFermentableDialog(
      existing: existing,
      onAddToRecipe: (updated) {
        setState(() {
          fermentables[index] = updated;
        });
        calculateStats();
      },
      onAddToInventory: (_) {},
    ),
  );
}


  void addAdditive(Map<String, dynamic> a) {
    setState(() {
      additives.add(a);
    });
    logger.d("Added additive: \${a['name']}");
  }

  void saveRecipe() {
  showDialog(
    context: context,
    builder: (_) {
      final nameController = TextEditingController(
        text: widget.existingRecipe?.name ?? '',
      );
      return AlertDialog(
        title: Text(widget.isClone ? "Clone Recipe" : widget.existingRecipe != null ? "Edit Recipe" : "Save Recipe"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: "Recipe Name"),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final recipeName = nameController.text;

              final newRecipe = RecipeModel(
                name: recipeName,
                tags: widget.existingRecipe?.tags ?? [],
                createdAt: DateTime.now(),
                og: og,
                fg: fg,
                abv: abv,
                additives: additives,
                fermentables: fermentables,
                fermentationStages: fermentationStages,
              );

              final box = Hive.box<RecipeModel>('recipes');

              if (widget.existingRecipe != null && !widget.isClone && widget.recipeKey != null) {
                await box.put(widget.recipeKey, newRecipe);
              } else {
                await box.add(newRecipe);
              }

              logger.i("${widget.isClone ? "Cloned" : widget.existingRecipe != null ? "Updated" : "Saved"} recipe: $recipeName");

              if (!mounted) return;

              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const RecipeListPage()),
              );
            },
            child: const Text("Save"),
          ),
        ],
      );
    },
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
              ),
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
              subtitle: Text(
                 "${f['amount'] ?? '—'} ${f['unit'] ?? ''}, OG: ${f['og']?.toStringAsFixed(3) ?? '—'}"
              ),
                
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => editFermentable(i),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        fermentables.removeAt(i);
                      });
                      calculateStats();
                    },
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 24),

          _buildSectionTitle("Additives", onAdd: () async {
            final result = await showDialog<Map<String, dynamic>>(
              context: context,
              builder: (_) => AddAdditiveDialog(
                mustPH: 3.4,
                volume: 5.0,
                onAdd: addAdditive,
              ),
            );
            if (result != null) addAdditive(result);
          }),
          ...additives.asMap().entries.map((entry) {
            final i = entry.key;
            final a = entry.value;
            return ListTile(
              title: Text(a['name']),
              subtitle: Text("${a['amount']} ${a['unit']}"),              
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    additives.removeAt(i);
                  });
                },
              ),
            );
          }),

          const SizedBox(height: 24),

          _buildSectionTitle("Fermentation Profile", onAdd: () async {
            await showDialog<Map<String, dynamic>>(
              context: context,
              builder: (_) => AddFermentationStageDialog(
                onSave: (stage) {
                  setState(() {
                    fermentationStages.add(stage);
                  });
                },
              ),
            );
          }),
          ...fermentationStages.asMap().entries.map((entry) {
            final i = entry.key;
            final stage = entry.value;
            return ListTile(
              title: Text(stage['name']),
              subtitle: Text("${stage['days']} days @ ${TempDisplay.format(stage['temp'])}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      await showDialog<Map<String, dynamic>>(
                        context: context,
                        builder: (_) => AddFermentationStageDialog(
                          existing: stage,
                          onSave: (updatedStage) {
                            setState(() {
                              fermentationStages[i] = updatedStage;
                            });
                          },
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        fermentationStages.removeAt(i);
                      });
                    },
                  ),
                ],
              ),
            );
          }),

          const Divider(thickness: 1.5),

          if (showAdvanced) ...[
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
        ],
      ),
    );
  }
}
