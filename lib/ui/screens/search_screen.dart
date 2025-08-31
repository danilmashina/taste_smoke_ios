import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/search_bloc.dart';
import '../../blocs/search_event.dart';
import '../../blocs/search_state.dart';
import '../components/mix_detail_dialog.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Поиск миксов'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Введите название микса',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      context.read<SearchBloc>().add(PerformSearch(_searchController.text));
                    },
                  ),
                ),
                onSubmitted: (value) {
                  context.read<SearchBloc>().add(PerformSearch(value));
                },
              ),
            ),
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state is SearchInitial) {
                    return const Center(child: Text('Начните поиск.'));
                  }
                  if (state is SearchLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is SearchResultsLoaded) {
                    if (state.results.isEmpty) {
                      return const Center(child: Text('Ничего не найдено.'));
                    }
                    return ListView.builder(
                      itemCount: state.results.length,
                      itemBuilder: (context, index) {
                        final mix = state.results[index];
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
                  if (state is SearchError) {
                    return Center(child: Text(state.message));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}