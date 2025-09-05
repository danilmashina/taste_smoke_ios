import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/create_mix_bloc.dart';
import '../../blocs/create_mix_event.dart';
import '../../blocs/create_mix_state.dart';
import '../components/tobacco_ingredients_editor.dart';
import '../theme.dart';

class CreateMixScreen extends StatelessWidget {
  const CreateMixScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateMixBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Создать микс'),
        ),
        body: BlocConsumer<CreateMixBloc, CreateMixState>(
          listener: (context, state) {
            if (state.status == FormStatus.submissionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Микс успешно сохранен!')),
              );
              // Optionally navigate back or clear the form
            } else if (state.status == FormStatus.submissionFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage ?? 'Ошибка сохранения')),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Label like on Android: "Введите ваш микс: *"
                  const Text(
                    'Введите ваш микс: *',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Описание микса',
                      border: const OutlineInputBorder(),
                      counterText: '${0} / 135', // will be overridden below by buildCounter
                    ),
                    maxLines: 4,
                    maxLength: 135,
                    buildCounter: (
                      BuildContext context, {
                      required int currentLength,
                      required bool isFocused,
                      required int? maxLength,
                    }) {
                      return Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${currentLength} / ${maxLength ?? 135}',
                          style: const TextStyle(color: secondaryText, fontSize: 12),
                        ),
                      );
                    },
                    onChanged: (value) =>
                        context.read<CreateMixBloc>().add(DescriptionChanged(value)),
                  ),
                  // Helper lines under description
                  Builder(
                    builder: (context) {
                      final state = context.watch<CreateMixBloc>().state;
                      final List<Widget> helpers = [];
                      if (state.descriptionLength < 10) {
                        helpers.add(const Text(
                          'Минимум 10 символов, чтобы опубликовать микс',
                          style: TextStyle(color: accentPink, fontSize: 12),
                        ));
                      }
                      if (state.hasProfanity) {
                        helpers.add(const Text(
                          'Текст содержит недопустимые слова',
                          style: TextStyle(color: Colors.redAccent, fontSize: 12),
                        ));
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: helpers,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Strength selection with required marker and helper
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Выбор крепости *',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        value: context.watch<CreateMixBloc>().state.strength.isEmpty
                            ? null
                            : context.watch<CreateMixBloc>().state.strength,
                        items: ['Легкий', 'Средний', 'Крепкий']
                            .map((label) => DropdownMenuItem(
                                  value: label,
                                  child: Text(label),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            context.read<CreateMixBloc>().add(StrengthChanged(value));
                          }
                        },
                      ),
                      Builder(
                        builder: (context) {
                          final hasStrength = context.watch<CreateMixBloc>().state.strength.isNotEmpty;
                          return hasStrength
                              ? const SizedBox.shrink()
                              : const Padding(
                                  padding: EdgeInsets.only(top: 6),
                                  child: Text(
                                    'Выберите крепость для сохранения микса',
                                    style: TextStyle(color: accentPink, fontSize: 12),
                                  ),
                                );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TobaccoIngredientsEditor(
                    ingredients: state.ingredients,
                    onIngredientsChange: (newIngredients) {
                      context.read<CreateMixBloc>().add(IngredientsChanged(newIngredients));
                    },
                  ),
                  const SizedBox(height: 32),
                  if (state.status == FormStatus.submissionInProgress)
                    const Center(child: CircularProgressIndicator())
                  else
                    ElevatedButton(
                      onPressed: state.isFormValid
                          ? () => context.read<CreateMixBloc>().add(SavePrivateMix())
                          : null, // Disable button if form is invalid
                      child: const Text('Сохранить свой микс'),
                    ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: state.isFormValid
                        ? () {
                            // In a real app, you'd show a dialog to select a category
                            context.read<CreateMixBloc>().add(const PublishPublicMix('Фрукты'));
                          }
                        : null,
                    child: const Text('Поделиться миксом'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
