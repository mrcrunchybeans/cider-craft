import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/tag.dart';
import 'package:flutter_application_1/utils/temp_display.dart';
import 'package:logger/logger.dart';
import 'package:hive/hive.dart';
import 'widgets/add_additive_dialog.dart';
import 'widgets/add_fermentation_stage_dialog.dart';
import 'widgets/add_fermentable_dialog.dart';
import 'utils/utils.dart';
import 'models/recipe_model.dart';
import 'recipe_list_page.dart';
import 'package:provider/provider.dart';
import 'widgets/tag_picker_dialog.dart';
import 'package:flutter_application_1/models/tag_manager.dart';
import 'widgets/add_yeast_dialog.dart';


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
  final TextEditingController nameController = TextEditingController();
  bool get hasAnyOg => fermentables.any((f) => f.containsKey('og') && f['og'] != null);
  double abv = 0.0;
  List<Map<String, dynamic>> additives = [];
  List<Map<String, dynamic>> fermentables = [];
  List<Map<String, dynamic>> yeast = [];
  List<Map<String, dynamic>> fermentationStages = [];
  List<Tag> tags = [];
  double fg = 1.010;
  double? og;
  bool showAdvanced = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingRecipe != null) {
      final recipe = widget.existingRecipe!;
      nameController.text = recipe.name;
      notesController.text = recipe.notes;
      additives = List<Map<String, dynamic>>.from(recipe.additives);
      fermentables = List<Map<String, dynamic>>.from(recipe.fermentables);
      fermentationStages = List<Map<String, dynamic>>.from(recipe.fermentationStages);
      og = recipe.og;
      fg = recipe.fg;
      abv = recipe.abv;
      yeast = List<Map<String, dynamic>>.from(recipe.yeast);
      tags = List<Tag>.from(recipe.tags);
    }
    calculateStats();
  }

    void calculateStats() {
    fg = CiderUtils.estimateFG();
    abv = CiderUtils.calculateABV(og ?? 1.000, fg);
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
  final existing = fermentables[index];

  await showDialog<Map<String, dynamic>>(
    context: context,
    builder: (_) => AddFermentableDialog(
      existing: existing,
      onAddToRecipe: (updated) {
        setState(() {
          fermentables[index] = updated;
          // Update OG if the updated fermentable has a valid OG value
          if (updated.containsKey('og') && updated['og'] != null) {
            og = updated['og'];
          }
        });
        calculateStats();
      },
      onAddToInventory: (_) {},
    ),
  );
}

  void editAdditive(int index) async {
    final existing = additives[index];

    await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => AddAdditiveDialog(
        mustPH: 3.4,
        volume: 5.0,
        existing: existing,
        onAdd: (updated) {
          setState(() {
            additives[index] = updated;
          });
          calculateStats();
        },
      ),
    );
  }

TextEditingController notesController = TextEditingController();


void addYeast(Map<String, dynamic> y) {
  setState(() {
    yeast = [y]; // Only one yeast allowed, replace any existing
  });
  logger.d("Added yeast: ${y['name']}");
}

void editYeast() async {
  final existing = yeast.isNotEmpty ? yeast.first : null;

  await showDialog<Map<String, dynamic>>(
    context: context,
    builder: (_) => AddYeastDialog(
      existing: existing,
      onAdd: (updated) {
        setState(() {
          yeast = [updated];
        });
      },
    ),
  );
}


  void addAdditive(Map<String, dynamic> a) {
    setState(() {
      additives.add(a);
    });
    logger.d("Added additive: ${a['name']}");
  }

  void saveRecipe() {
  final recipeName = nameController.text.trim();

  if (recipeName.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please enter a recipe name.")),
    );
    return;
  }

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Confirm Save"),
      content: Text("Save recipe as \"$recipeName\"?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () async {
            final newRecipe = RecipeModel(
              name: recipeName,
              tags: tags,
              createdAt: DateTime.now(),
              og: og ?? 1.000,
              fg: fg,
              abv: abv,
              additives: additives,
              fermentables: fermentables,
              yeast: yeast,
              fermentationStages: fermentationStages,
              notes: notesController.text.trim(),

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

  @override
  Widget build(BuildContext context) {
    Provider.of<TagManager>(context);
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

          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: "Recipe Name",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Tags", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: tags.map((tag) => Chip(label: Text(tag.name))).toList(),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.label),
                label: const Text("Choose Tags"),
                onPressed: () async {
                  final result = await showTagPickerDialog(context, tags);
                  if (result != null) {
                    setState(() => tags = result);
                  }
                },
              ),
              const Divider(thickness: 1.2),
            ],
          ),

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
              subtitle: Text("${f['amount'] ?? '—'} ${f['unit'] ?? ''}, OG: ${f['og']?.toStringAsFixed(3) ?? '—'}"),
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
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => editAdditive(i),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        additives.removeAt(i);
                      });
                    },
                  ),
                ],
              ),
            );
          }),


          const SizedBox(height: 24),

          _buildSectionTitle("Yeast", onAdd: () async {
            final result = await showDialog<Map<String, dynamic>>(
              context: context,
              builder: (_) => AddYeastDialog(
                onAdd: addYeast,
                existing: yeast.isNotEmpty ? yeast.first : null,

              ),
            );
            if (result != null) addYeast(result);
          }),
          ...yeast.map((y) => ListTile(
            title: Text(y['name']),
            subtitle: Text("${y['amount']} ${y['unit']}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: editYeast,
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() => yeast.clear());
                  },
                ),
              ],
            ),
          )),

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

                    TextFormField(
            controller: notesController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: "Notes",
              hintText: "Any extra information, comments, or observations",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),

          const Divider(thickness: 1.5),

  if (og != null || showAdvanced) ...[
    if (og != null)
      ListTile(
        title: const Text("Original Gravity"),
        subtitle: Text(og!.toStringAsFixed(3)),
      ),
          const SizedBox(height: 12),
      // Final Gravity field with ABV recalculation
        TextFormField(
          initialValue: fg.toStringAsFixed(3),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: "Final Gravity",
            border: OutlineInputBorder(),
          ),
          onChanged: (val) {
            final parsed = double.tryParse(val);
            if (parsed != null && parsed >= 0.990 && parsed <= 1.200) {
              setState(() {
                fg = parsed;
                abv = CiderUtils.calculateABV(og ?? 1.000, fg);
              });
            }
          },
        ),
      const SizedBox(height: 12),
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