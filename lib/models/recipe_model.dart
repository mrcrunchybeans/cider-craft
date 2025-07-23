import 'package:hive/hive.dart';
import 'tag.dart';

part 'recipe_model.g.dart';

@HiveType(typeId: 0)
class RecipeModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  DateTime createdAt;

  @HiveField(2)
  List<Tag> tags;

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

  @HiveField(9)
  List<Map<String, dynamic>> yeast;

  @HiveField(10)
  String notes;
  
  @HiveField(11)
  DateTime? lastOpened;

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
    required this.yeast,
    this.notes = '',

  });
}
