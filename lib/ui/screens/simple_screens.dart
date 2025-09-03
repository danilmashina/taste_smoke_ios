import 'package:flutter/material.dart';

class SimpleCategoriesScreen extends StatelessWidget {
  const SimpleCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: null,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category, size: 64),
            SizedBox(height: 16),
            Text('Категории', style: TextStyle(fontSize: 24)),
            SizedBox(height: 8),
            Text('Экран в разработке'),
          ],
        ),
      ),
    );
  }
}

class SimpleFavoritesScreen extends StatelessWidget {
  const SimpleFavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: null,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite, size: 64),
            SizedBox(height: 16),
            Text('Избранное', style: TextStyle(fontSize: 24)),
            SizedBox(height: 8),
            Text('Экран в разработке'),
          ],
        ),
      ),
    );
  }
}

class SimpleProfileScreen extends StatelessWidget {
  const SimpleProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: null,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 64),
            SizedBox(height: 16),
            Text('Профиль', style: TextStyle(fontSize: 24)),
            SizedBox(height: 8),
            Text('Экран в разработке'),
          ],
        ),
      ),
    );
  }
}

class SimpleSearchScreen extends StatelessWidget {
  const SimpleSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Поиск'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64),
            SizedBox(height: 16),
            Text('Поиск', style: TextStyle(fontSize: 24)),
            SizedBox(height: 8),
            Text('Экран в разработке'),
          ],
        ),
      ),
    );
  }
}

class SimpleCategoryDetailScreen extends StatelessWidget {
  final String categoryName;
  
  const SimpleCategoryDetailScreen({
    super.key,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.category, size: 64),
            const SizedBox(height: 16),
            Text(categoryName, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            const Text('Детали категории в разработке'),
          ],
        ),
      ),
    );
  }
}

class SimpleCreateMixScreen extends StatelessWidget {
  const SimpleCreateMixScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создать микс'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 64),
            SizedBox(height: 16),
            Text('Создать микс', style: TextStyle(fontSize: 24)),
            SizedBox(height: 8),
            Text('Экран в разработке'),
          ],
        ),
      ),
    );
  }
}

class SimpleMyMixesScreen extends StatelessWidget {
  const SimpleMyMixesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои миксы'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.list, size: 64),
            SizedBox(height: 16),
            Text('Мои миксы', style: TextStyle(fontSize: 24)),
            SizedBox(height: 8),
            Text('Экран в разработке'),
          ],
        ),
      ),
    );
  }
}