import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/popular_mixes_bloc.dart';
import '../../blocs/popular_mixes_state.dart';
import 'mix_detail_dialog.dart';

class PopularMixesSection extends StatelessWidget {
  const PopularMixesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Популярные миксы недели',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        BlocBuilder<PopularMixesBloc, PopularMixesState>(
          builder: (context, state) {
            if (state is PopularMixesLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is PopularMixesLoaded) {
              if (state.mixes.isEmpty) {
                return const Center(child: Text('Популярных миксов пока нет.'));
              }
              return SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.mixes.length,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  itemBuilder: (context, index) {
                    final mix = state.mixes[index];
                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => MixDetailDialog(mix: mix),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 150,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (mix.image != null)
                                Expanded(
                                  child: Center(
                                    child: Image.network(
                                      mix.image!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  mix.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }
            if (state is PopularMixesError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink(); // Initial state
          },
        ),
      ],
    );
  }
}
