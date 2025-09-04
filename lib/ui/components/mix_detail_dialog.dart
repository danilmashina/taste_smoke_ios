import 'package:flutter/material.dart';
import '../../data/models/mix.dart';

class MixDetailDialog extends StatelessWidget {
  final Mix mix;

  const MixDetailDialog({super.key, required this.mix});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(mix.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (mix.image != null)
            Image.network(mix.image!),
          const SizedBox(height: 16),
          Text(mix.description),
          const SizedBox(height: 16),
          const Text('Ингредиенты:', style: TextStyle(fontWeight: FontWeight.bold)),
          for (final ingredient in mix.ingredients)
            Text('- ${ingredient.tobacco} (${ingredient.percentage}%)'),
        ],
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