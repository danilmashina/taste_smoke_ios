import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/create_mix_bloc.dart';
import '../../blocs/create_mix_event.dart';
import '../../blocs/create_mix_state.dart';
import '../components/tobacco_ingredients_editor.dart';

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
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Описание микса',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                    onChanged: (value) =>
                        context.read<CreateMixBloc>().add(DescriptionChanged(value)),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Крепость',
                      border: OutlineInputBorder(),
                    ),
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
