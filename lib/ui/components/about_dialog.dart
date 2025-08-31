import 'package:flutter/material.dart';

class AboutDialogContent extends StatelessWidget {
  const AboutDialogContent({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('О приложении TasteSmoke'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TasteSmoke - Ваша личная коллекция кальянных рецептов и техник теперь в смартфоне! TasteSmoke — это идеальный помощник для ценителей кальяна: будь вы новичок, экспериментатор или профессиональный кальянщик.',
            ),
            const SizedBox(height: 12),
            const Text(
              'Откройте для себя мир кальянных вкусов с нашим приложением. Более 100 рецептов, советы от профессионалов и возможность создавать собственные миксы.',
            ),
            const SizedBox(height: 16),
            const Text(
              '💨 Каталог забивок: «с колодцем», «в касание» и другие техники — теперь все в одном месте',
            ),
            const SizedBox(height: 8),
            const Text(
              '🍃 Категории табаков и миксов: легко найти подходящий вкус.',
            ),
            const SizedBox(height: 8),
            const Text(
              '⭐️ Избранное: сохраняйте лучшие миксы и возвращайтесь к ним в любое время.',
            ),
            const SizedBox(height: 8),
            const Text(
              '🧠 Уровень сложности: оцените свои навыки и выберите забивку по силам.',
            ),
            const SizedBox(height: 8),
            const Text(
              '👤 Профиль пользователя: отслеживайте свою активность и делитесь своими миксами.',
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
