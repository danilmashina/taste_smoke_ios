import 'package:flutter/material.dart';

class HelpBottomSheetContent extends StatelessWidget {
  const HelpBottomSheetContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Описание функционала',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildHelpSection('Лайки', 'Отмечайте понравившиеся миксы. Лайки помогают авторам и поднимают ваши миксы в миксы недели.'),
          _buildHelpSection('Подписки и подписчики', 'Подписывайтесь на авторов, чтобы видеть их новые миксы. Ваши подписчики — пользователи, которым интересны ваши миксы.'),
          _buildHelpSection('Мои миксы', 'Ваши личные миксы. Можно редактировать, публиковать или удалять.'),
          _buildHelpSection('Избранное', 'Быстрый доступ к любимым миксам. Добавляйте/удаляйте через иконку.'),
          _buildHelpSection('Публикации', 'Публичные миксы видны всем. Указывайте категорию, чтобы упростить поиск.'),
          _buildHelpSection('Категории', 'Тематические группы (Фрукты, Ягоды, Десерты и др.). Помогают фильтровать миксы.'),
          _buildHelpSection('Система уровней в профиле', 'Уровень повышается по суммарным лайкам. Ключевые пороги: 10 / 50 / 100 / 150 лайков.\nНачинающий: 0–9 лайков\nНовичок: 10–49 лайков\nЛюбитель: 50–99 лайков\nЭксперт: 100–149 лайков\nМастер: 150+ лайков (максимальный уровень)\nПереход на следующий уровень происходит при достижении соответствующего порога.'),
          _buildHelpSection('Профиль и никнейм', 'Ник отображается как автор публикации. Его можно изменить в профиле.'),
          _buildHelpSection('Крепость и состав табака', 'Указывайте крепость и вкусы с граммовкой — это помогает другим повторить микс.'),
          _buildHelpSection('Условия публикации', 'Описание: минимум 10 символов, максимум 135; до 4 строк. Ненормативная лексика запрещена.'),
          _buildHelpSection('Фильтр мата и модерация', 'Мы автоматически блокируем тексты с матом. Нарушения могут приводить к скрытию публикаций.'),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(content),
        const SizedBox(height: 8),
      ],
    );
  }
}
