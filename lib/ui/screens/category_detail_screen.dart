import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/mixes_by_category_bloc.dart';
import '../../blocs/mixes_by_category_event.dart';
import '../../blocs/mixes_by_category_state.dart';
import '../components/mix_detail_dialog.dart';

class CategoryDetailScreen extends StatelessWidget {
  final String categoryName;

  const CategoryDetailScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MixesByCategoryBloc()..add(FetchMixesByCategory(categoryName)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(categoryName),
        ),
        body: BlocBuilder<MixesByCategoryBloc, MixesByCategoryState>(
          builder: (context, state) {
            if (state is MixesByCategoryLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is MixesByCategoryLoaded) {
              if (state.mixes.isEmpty) {
                return const Center(
                  child: Text('В этой категории пока нет миксов.'),
                );
              }
              return ListView.builder(
                itemCount: state.mixes.length,
                itemBuilder: (context, index) {
                  final mix = state.mixes[index];
                  return ListTile(
                    leading: mix.image != null
                        ? Image.network(mix.image!, width: 56, height: 56, fit: BoxFit.cover)
                        : const Icon(Icons.local_bar, size: 56),
                    title: Text(mix.name),
                    subtitle: Text(mix.author),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => MixDetailDialog(mix: mix),
                      );
                    },
                  );
                },
              );
            }
            if (state is MixesByCategoryError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}