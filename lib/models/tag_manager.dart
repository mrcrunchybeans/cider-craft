// lib/models/tag_manager.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'tag.dart'; // Import the correct Tag model

class TagManager extends ChangeNotifier {
  final Box<Tag> _tagBox = Hive.box<Tag>('tags');

  List<Tag> get tags => _tagBox.values.cast<Tag>().toList();

  void addTag(String name) {
    if (!_tagBox.values.any((tag) => tag.name == name)) {
      _tagBox.add(Tag(name));
      notifyListeners();
    }
  }

  void deleteTag(Tag tag) {
    final key = _tagBox.keys.firstWhere((k) => _tagBox.get(k) == tag, orElse: () => null);
    if (key != null) {
      _tagBox.delete(key);
      notifyListeners();
    }
  }

  void editTag(Tag oldTag, String newName) {
    final key = _tagBox.keys.firstWhere((k) => _tagBox.get(k) == oldTag, orElse: () => null);
    if (key != null) {
      _tagBox.put(key, Tag(newName));
      notifyListeners();
    }
  }
}
