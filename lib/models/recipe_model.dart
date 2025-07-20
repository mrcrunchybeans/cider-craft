import 'package:hive/hive.dart';

part 'recipe_model.g.dart';

@HiveType(typeId: 0)
class RecipeModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  List<String> tags;

  @HiveField(2)
  DateTime createdAt;

  @HiveField(3)
  double og;

  @HiveField(4)
  double fg;

  @HiveField(5)
  double abv;

  @HiveField(6)
  List<Map<String, dynamic>> additives;

  @HiveField(7)
  List<Map<String, dynamic>> fermentables;

  @HiveField(8)
  List<Map<String, dynamic>> fermentationStages;

  RecipeModel({
    required this.name,
    required this.tags,
    required this.createdAt,
    required this.og,
    required this.fg,
    required this.abv,
    required this.additives,
    required this.fermentables,
    required this.fermentationStages,
  });
}
