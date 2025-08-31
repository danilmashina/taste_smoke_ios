import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/favorites_bloc.dart';
import '../../blocs/favorites_event.dart';
import '../../blocs/favorites_state.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FavoritesBloc()..add(LoadFavorites()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Избранное'),
        ),
        body: BlocBuilder<FavoritesBloc, FavoritesState>(
          builder: (context, state) {
            if (state is FavoritesLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is FavoritesLoaded) {
              if (state.favoriteMixes.isEmpty) {
                return const Center(
                  child: Text('У вас пока нет избранных миксов.'),
                );
              }
              return ListView.builder(
                itemCount: state.favoriteMixes.length,
                itemBuilder: (context, index) {
                  final mix = state.favoriteMixes[index];
                  return ListTile(
                    leading: mix.image != null
                        ? Image.network(mix.image!, width: 56, height: 56, fit: BoxFit.cover)
                        : const Icon(Icons.local_bar, size: 56),
                    title: Text(mix.name),
                    subtitle: Text(mix.author),
                    onTap: () {
                      // TODO: Navigate to mix detail screen
                    },
                  );
                },
              );
            }
            if (state is FavoritesError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text('Welcome to your favorites!'));
          },
        ),
      ),
    );
  }
}