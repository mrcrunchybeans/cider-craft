// lib/recipe_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/recipe_detail_page.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import 'models/recipe_model.dart';
import 'recipe_builder_page.dart'; // Make sure this import exists!

class RecipeListPage extends StatefulWidget {
  const RecipeListPage({super.key});

  @override
  State<RecipeListPage> createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  late Box<RecipeModel> _recipeBox;

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
      ),
      body: ValueListenableBuilder(
        valueListenable: _recipeBox.listenable(),
        builder: (context, Box<RecipeModel> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('No recipes saved yet.'));
          }

          final recipes = box.values.toList();

          return ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return Card(
                child: ListTile(
                  title: Text(recipe.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tags: ${recipe.tags.join(", ")}'),
                      Text('Created: ${DateFormat.yMMMd().format(recipe.createdAt)}'),
                    ],
                  ),
                  onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => RecipeDetailPage(recipe: recipe, index: index),
    ),
  );
},


                ),
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
