import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/my_mixes_bloc.dart';
import '../../blocs/my_mixes_event.dart';
import '../../blocs/my_mixes_state.dart';
import '../components/mix_card.dart';
import '../components/edit_mix_dialog.dart';

class MyMixesScreen extends StatelessWidget {
  const MyMixesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MyMixesBloc()..add(LoadMyMixes()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Мои миксы'),
        ),
        body: BlocBuilder<MyMixesBloc, MyMixesState>(
          builder: (context, state) {
            if (state is MyMixesLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is MyMixesLoaded) {
              if (state.mixes.isEmpty) {
                return const Center(
                  child: Text('У вас пока нет сохраненных миксов.'),
                );
              }
              return ListView.builder(
                itemCount: state.mixes.length,
                itemBuilder: (context, index) {
                  final mix = state.mixes[index];
                  return MixCard(
                    mix: mix,
                    onEdit: () {
                      showDialog(
                        context: context,
                        builder: (_) => EditMixDialog(
                          mix: mix,
                          onSave: (newText, newIngredients, newStrength) {
                            context.read<MyMixesBloc>().add(UpdateMyMix(
                                  mixId: mix.id,
                                  newText: newText,
                                  newIngredients: newIngredients,
                                  newStrength: newStrength,
                                ));
                            Navigator.of(context).pop(); // Close dialog
                          },
                          onDismiss: () => Navigator.of(context).pop(),
                        ),
                      );
                    },
                    onDelete: () {
                      context.read<MyMixesBloc>().add(DeleteMyMix(mix.id));
                    },
                  );
                },
              );
            }
            if (state is MyMixesError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text('Welcome to My Mixes!'));
          },
        ),
      ),
    );
  }
}
