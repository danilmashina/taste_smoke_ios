import 'package:flutter/material.dart';
import '../../data/public_mix.dart';

class MixDetailDialog extends StatelessWidget {
  final PublicMix mix;

  const MixDetailDialog({super.key, required this.mix});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(mix.name),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (mix.image != null)
              Center(
                child: Image.network(
                  mix.image!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text('Автор: ${mix.author}'),
            const SizedBox(height: 8),
            Text(mix.description),
            const SizedBox(height: 16),
            const Text('Ингредиенты:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...mix.ingredients.map((ingredient) => Text(
                  '  • ${ingredient.tobacco} - ${ingredient.flavor}: ${ingredient.percentage}%',
                )),
            const SizedBox(height: 16),
            Text('Крепость: ${mix.strength}'),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.favorite, color: Colors.pinkAccent),
                const SizedBox(width: 4),
                Text(mix.likes.toString()),
                const SizedBox(width: 16),
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 4),
                Text(mix.rating.toStringAsFixed(1)),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Закрыть'),
        ),
      ],
    );
  }
}
