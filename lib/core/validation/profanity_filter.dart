// lib/core/validation/profanity_filter.dart
// Фильтр нецензурной брани, синхронизированный с Android-логикой.
// Алгоритм:
// 1) Нормализация текста: lower, замена leet-символов, удаление пунктуации и пробелов,
//    приведение "ё"->"е" и схлопывание повторяющихся символов.
// 2) Проверка по списку stem'ов (фрагменты слов).

class ProfanityFilter {
  // Соответствует Kotlin-файлу: TobaccoIngredientsEditor.kt (profanityStems)
  static const List<String> _stems = <String>[
    // RU stems
    'хер', 'хуй', 'пизд', 'ебат', 'ебал', 'ебан', 'ебло', 'сука', 'бля', 'залуп', 'сиськ',
    'ахуенн', 'хуев', 'ебуч', 'невьеб', 'невъеб', 'уебан', 'суч', 'уебск', 'чмо',
    'пенис', 'член', 'ебей', 'жопа', 'анус',
    // EN stems
    'fuck', 'shit', 'ass', 'dick', 'cunt',
  ];

  static bool contains(String text) {
    final normalized = _normalize(text);
    for (final stem in _stems) {
      if (normalized.contains(stem)) return true;
    }
    return false;
  }

  static String _normalize(String input) {
    final Map<String, String> leetMap = {
      '0': 'o',
      '1': 'i',
      '3': 'e',
      '4': 'a',
      '5': 's',
      '7': 't',
      '@': 'a',
      'ё': 'е',
    };

    final lower = input.toLowerCase();
    final buf = StringBuffer();
    // Используем обычную строку с экранированием, чтобы включить и двойную, и одинарную кавычки
    final punctuation = RegExp("[\\s\\t\\n\\.,\\-_'`!\\?\\:;\"\\(\\)\\[\\]\\{\\}\\|]");
    String? prevChar;
    for (final rune in lower.runes) {
      final ch = String.fromCharCode(rune);
      // Убираем пробелы и пунктуацию
      if (punctuation.hasMatch(ch)) {
        continue;
      }
      buf.write(leetMap[ch] ?? ch);
    }

    // Схлопываем повторяющиеся символы
    final sb = StringBuffer();
    String? prev;
    for (final rune in buf.toString().runes) {
      final ch = String.fromCharCode(rune);
      if (prev == null || prev != ch) {
        sb.write(ch);
        prev = ch;
      }
    }
    return sb.toString();
  }
}
