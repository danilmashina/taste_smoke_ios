import 'package:flutter/material.dart';
import '../../data/private_mix.dart';

class MixCard extends StatelessWidget {
  final PrivateMix mix;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MixCard({
    super.key,
    required this.mix,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Микс',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(mix.description),
            const SizedBox(height: 8),
            Text('Крепость: ${mix.strength}'),
            const SizedBox(height: 8),
            if (mix.ingredients.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ингредиенты:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...mix.ingredients.map((i) => Text(
                        '  • ${i.tobacco} - ${i.flavor}: ${i.percentage}%',
                      )),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
