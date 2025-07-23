  // lib/recipe_list_page.dart

  import 'package:flutter/material.dart';
  import 'package:flutter_application_1/recipe_detail_page.dart';
  import 'package:flutter_application_1/recipe_builder_page.dart';
  import 'package:hive_flutter/hive_flutter.dart';
  import 'package:intl/intl.dart';
  import 'models/recipe_model.dart';

enum SortMode { dateCreated, aToZ, zToA, recentlyOpened }

  class RecipeListPage extends StatefulWidget {
    const RecipeListPage({super.key});

    @override
    State<RecipeListPage> createState() => _RecipeListPageState();
  }

  class _RecipeListPageState extends State<RecipeListPage> {
    late Box<RecipeModel> _recipeBox;
    String? expandedTag;
    SortMode _sortMode = SortMode.dateCreated;



    @override
    void initState() {
      super.initState();
      _recipeBox = Hive.box<RecipeModel>('recipes');
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
  title: const Text('Saved Recipes'),
  actions: [
    PopupMenuButton<SortMode>(
      onSelected: (mode) => setState(() => _sortMode = mode),
      icon: const Icon(Icons.sort),
      itemBuilder: (_) => [
        const PopupMenuItem(value: SortMode.dateCreated, child: Text("Date Created")),
        const PopupMenuItem(value: SortMode.aToZ, child: Text("A → Z")),
        const PopupMenuItem(value: SortMode.zToA, child: Text("Z → A")),
        const PopupMenuItem(value: SortMode.recentlyOpened, child: Text("Recently Opened")),
      ],
    ),
  ],
),

        body: ValueListenableBuilder(
          valueListenable: _recipeBox.listenable(),
          builder: (context, Box<RecipeModel> box, _) {
            if (box.isEmpty) {
              return const Center(child: Text('No recipes saved yet.'));
            }

            final Map<String, List<RecipeModel>> grouped = {};

List<RecipeModel> sortedRecipes = box.values.toList();

switch (_sortMode) {
  case SortMode.dateCreated:
    sortedRecipes.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Newest first
    break;
  case SortMode.aToZ:
    sortedRecipes.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    break;
  case SortMode.zToA:
    sortedRecipes.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
    break;
  case SortMode.recentlyOpened:
    sortedRecipes.sort((a, b) => b.lastOpened?.compareTo(a.lastOpened ?? DateTime.fromMillisecondsSinceEpoch(0)) ?? 0);
    break;
}


            for (var recipe in sortedRecipes) {
              final tags = recipe.tags.isEmpty ? ['No Tag'] : recipe.tags.map((t) => t.name);
              for (var tag in tags) {
                grouped.putIfAbsent(tag, () => []).add(recipe);
              }
            }

            final sortedKeys = grouped.keys.toList()..sort();

            return ListView.builder(
              itemCount: sortedKeys.length,
              itemBuilder: (context, index) {
                final tag = sortedKeys[index];
                final recipes = grouped[tag]!;

                return ExpansionTile(
                  title: Text(tag),
                  initiallyExpanded: index == 0, // ✅ auto-expand the first group
                  children: recipes.asMap().entries.map((entry) {
                    final recipe = entry.value;
                    final recipeIndex = box.values.toList().indexOf(recipe);

                    return ListTile(
                      title: Text(recipe.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tags: ${recipe.tags.map((t) => t.name).join(", ")}'),
                          Text('Created: ${DateFormat.yMMMd().format(recipe.createdAt)}'),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RecipeDetailPage(recipe: recipe, index: recipeIndex),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RecipeBuilderPage()),
            );
          },
          tooltip: 'New Recipe',
          child: const Icon(Icons.add),
        ),
      );
    }
  }
