import 'package:flutter/material.dart';

class TermsDialogContent extends StatelessWidget {
  const TermsDialogContent({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Условия использования'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '1. Общие положения',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              'Используя приложение TasteSmoke, вы соглашаетесь с данными условиями использования.',
            ),
            const SizedBox(height: 12),
            const Text(
              '2. Ответственность пользователя',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              '• Вы несете ответственность за содержание публикуемых миксов\n• Запрещено публиковать оскорбительный или неприемлемый контент\n• Использование приложения только в законных целях',
            ),
            const SizedBox(height: 12),
            const Text(
              '3. Конфиденциальность',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              'Мы защищаем вашу личную информацию и используем ее только для улучшения работы приложения.',
            ),
            const SizedBox(height: 12),
            const Text(
              '4. Возрастные ограничения',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              'Приложение предназначено для лиц старше 18 лет. Курение вредит вашему здоровью.',
            ),
            const SizedBox(height: 12),
            const Text(
              '5. Изменения условий',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              'Мы оставляем за собой право изменять данные условия. Продолжение использования приложения означает согласие с новыми условиями.',
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
