import 'package:flutter/material.dart';
import '../../data/tobacco_ingredient.dart';

class TobaccoIngredientsEditor extends StatefulWidget {
  final List<TobaccoIngredient> ingredients;
  final ValueChanged<List<TobaccoIngredient>> onIngredientsChange;

  const TobaccoIngredientsEditor({
    super.key,
    required this.ingredients,
    required this.onIngredientsChange,
  });

  @override
  State<TobaccoIngredientsEditor> createState() => _TobaccoIngredientsEditorState();
}

class _TobaccoIngredientsEditorState extends State<TobaccoIngredientsEditor> {
  late List<TobaccoIngredient> _ingredients;

  @override
  void initState() {
    super.initState();
    _ingredients = List.from(widget.ingredients);
  }

  void _addIngredient() {
    setState(() {
      _ingredients.add(const TobaccoIngredient(tobacco: '', flavor: '', percentage: 0));
    });
    widget.onIngredientsChange(_ingredients);
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
    widget.onIngredientsChange(_ingredients);
  }

  void _updateIngredient(int index, TobaccoIngredient ingredient) {
    setState(() {
      _ingredients[index] = ingredient;
    });
    widget.onIngredientsChange(_ingredients);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ингредиенты:', style: TextStyle(fontWeight: FontWeight.bold)),
        ..._ingredients.asMap().entries.map((entry) {
          int index = entry.key;
          TobaccoIngredient ingredient = entry.value;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: ingredient.tobacco,
                    decoration: const InputDecoration(labelText: 'Табак'),
                    onChanged: (value) {
                      _updateIngredient(index, TobaccoIngredient(tobacco: value, flavor: ingredient.flavor, percentage: ingredient.percentage));
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: ingredient.flavor,
                    decoration: const InputDecoration(labelText: 'Вкус'),
                    onChanged: (value) {
                      _updateIngredient(index, TobaccoIngredient(tobacco: ingredient.tobacco, flavor: value, percentage: ingredient.percentage));
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 60,
                  child: TextFormField(
                    initialValue: ingredient.percentage.toString(),
                    decoration: const InputDecoration(labelText: '%'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final percentage = int.tryParse(value) ?? 0;
                      _updateIngredient(index, TobaccoIngredient(tobacco: ingredient.tobacco, flavor: ingredient.flavor, percentage: percentage));
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => _removeIngredient(index),
                ),
              ],
            ),
          );
        }).toList(),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _addIngredient,
          icon: const Icon(Icons.add),
          label: const Text('Добавить ингредиент'),
        ),
      ],
    );
  }
}
