// lib/ui/components/searchable_picker.dart
import 'package:flutter/material.dart';
import '../../ui/theme.dart';

Future<String?> showSearchablePicker({
  required BuildContext context,
  required String title,
  required List<String> options,
  String? initialValue,
}) async {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: cardBackground,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      final TextEditingController controller =
          TextEditingController(text: initialValue ?? '');
      String query = controller.text;
      return StatefulBuilder(
        builder: (context, setState) {
          final filtered = query.isEmpty
              ? options
              : options
                  .where((o) => o.toLowerCase().contains(query.toLowerCase()))
                  .toList();
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: primaryText,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: secondaryText),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: 'Поиск...',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => setState(() => query = val),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(color: Colors.white12, height: 1),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return ListTile(
                          title: Text(item, style: const TextStyle(color: primaryText)),
                          onTap: () => Navigator.pop(context, item),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
