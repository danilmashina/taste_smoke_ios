import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/categories_bloc.dart';
import '../../blocs/categories_event.dart';
import '../../blocs/categories_state.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CategoriesBloc()..add(FetchCategories()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Категории'),
        ),
        body: BlocBuilder<CategoriesBloc, CategoriesState>(
          builder: (context, state) {
            if (state is CategoriesLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is CategoriesLoaded) {
              return GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: state.categories.length,
                itemBuilder: (context, index) {
                  final category = state.categories[index];
                  return Card(
                    child: InkWell(
                      onTap: () {
                        // TODO: Navigate to category detail screen
                      },
                      child: Center(
                        child: Text(
                          category.name,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ),
                  );
                },
              );
            }
            if (state is CategoriesError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text('Categories Screen'));
          },
        ),
      ),
    );
  }
}