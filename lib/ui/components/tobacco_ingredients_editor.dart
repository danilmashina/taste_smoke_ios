import 'package:flutter/material.dart';
import '../../data/tobacco_ingredient.dart';
import '../../data/tobacco_catalog.dart';
import 'searchable_picker.dart';

class TobaccoIngredientsEditor extends StatefulWidget {
  final List<TobaccoIngredient> ingredients;
  final ValueChanged<List<TobaccoIngredient>> onIngredientsChange;
  final int maxCount;

  const TobaccoIngredientsEditor({
    super.key,
    required this.ingredients,
    required this.onIngredientsChange,
    this.maxCount = 5,
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
    if (_ingredients.length >= widget.maxCount) {
      // Show a friendly message and do not add more than maxCount
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Можно добавить не более ${widget.maxCount} ингредиентов')),
      );
      return;
    }
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
        Text(
          'Ингредиенты (${_ingredients.length}/${widget.maxCount}):',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        ..._ingredients.asMap().entries.map((entry) {
          int index = entry.key;
          TobaccoIngredient ingredient = entry.value;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final selected = await showSearchablePicker(
                        context: context,
                        title: 'Марка',
                        options: tobaccoBrands,
                        initialValue: ingredient.tobacco,
                      );
                      if (selected != null) {
                        _updateIngredient(index, TobaccoIngredient(tobacco: selected, flavor: ingredient.flavor, percentage: ingredient.percentage));
                      }
                    },
                    child: AbsorbPointer(
                      child: TextFormField(
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Марка *',
                          suffixIcon: Icon(Icons.arrow_drop_down),
                        ),
                        controller: TextEditingController(text: ingredient.tobacco.isNotEmpty ? ingredient.tobacco : ''),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final selected = await showSearchablePicker(
                        context: context,
                        title: 'Вкус',
                        options: tobaccoFlavors,
                        initialValue: ingredient.flavor,
                      );
                      if (selected != null) {
                        _updateIngredient(index, TobaccoIngredient(tobacco: ingredient.tobacco, flavor: selected, percentage: ingredient.percentage));
                      }
                    },
                    child: AbsorbPointer(
                      child: TextFormField(
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Вкус *',
                          suffixIcon: Icon(Icons.arrow_drop_down),
                        ),
                        controller: TextEditingController(text: ingredient.flavor.isNotEmpty ? ingredient.flavor : ''),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 60,
                  child: TextFormField(
                    initialValue: ingredient.percentage.toString(),
                    decoration: const InputDecoration(labelText: '% *'),
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
          onPressed: _ingredients.length >= widget.maxCount ? null : _addIngredient,
          icon: const Icon(Icons.add),
          label: const Text('Добавить ингредиент'),
        ),
      ],
    );
  }
}
