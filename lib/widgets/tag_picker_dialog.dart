import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/tag.dart';
import 'package:flutter_application_1/models/tag_manager.dart';

Future<List<Tag>?> showTagPickerDialog(
  BuildContext context,
  List<Tag> selectedTags,
  TagManager tagManager,
) async {
  final Set<Tag> localSelection = Set.from(selectedTags);
  final TextEditingController controller = TextEditingController();

  return showDialog<List<Tag>>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Select Tags"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: 6.0,
            children: tagManager.tags.map((tag) {
              final selected = localSelection.contains(tag);
              return FilterChip(
                label: Text(tag.name),
                selected: selected,
                onSelected: (val) {
                  if (val) {
                    localSelection.add(tag);
                  } else {
                    localSelection.remove(tag);
                  }
                  (context as Element).markNeedsBuild();
                },
                onDeleted: () => tagManager.deleteTag(tag),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Add New Tag',
              suffixIcon: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  final name = controller.text.trim();
                  if (name.isNotEmpty) {
                    tagManager.addTag(name);
                    final addedTag = tagManager.tags.firstWhere((t) => t.name == name);
                    localSelection.add(addedTag);
                    controller.clear();
                    (context as Element).markNeedsBuild();
                  }
                },
              ),
            ),
          )
        ],
      ),
      actions: [
        TextButton(
          child: const Text("Cancel"),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: const Text("Done"),
          onPressed: () => Navigator.pop(context, localSelection.toList()),
        ),
      ],
    ),
  );
}
