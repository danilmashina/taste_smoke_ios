import 'package:flutter/material.dart';
import '../../data/private_mix.dart';
import '../../data/tobacco_ingredient.dart';
import './tobacco_ingredients_editor.dart';

class EditMixDialog extends StatefulWidget {
  final PrivateMix mix;
  final Function(String newText, List<TobaccoIngredient> newIngredients, String newStrength) onSave;
  final VoidCallback onDismiss;

  const EditMixDialog({
    super.key,
    required this.mix,
    required this.onSave,
    required this.onDismiss,
  });

  @override
  State<EditMixDialog> createState() => _EditMixDialogState();
}

class _EditMixDialogState extends State<EditMixDialog> {
  late TextEditingController _textController;
  late List<TobaccoIngredient> _ingredients;
  late String _strength;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.mix.description);
    _ingredients = List.from(widget.mix.ingredients);
    _strength = widget.mix.strength;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Редактировать микс'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(labelText: 'Описание микса'),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _strength,
              decoration: const InputDecoration(labelText: 'Крепость'),
              items: ['Легкий', 'Средний', 'Крепкий']
                  .map((label) => DropdownMenuItem(
                        value: label,
                        child: Text(label),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _strength = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TobaccoIngredientsEditor(
              ingredients: _ingredients,
              onIngredientsChange: (newIngredients) {
                setState(() {
                  _ingredients = newIngredients;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.onDismiss,
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(_textController.text, _ingredients, _strength);
          },
          child: const Text('Сохранить'),
        ),
      ],
    );
  }
}
