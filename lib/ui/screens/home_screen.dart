import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/auth_bloc.dart';
import '../../blocs/auth_event.dart';
import '../../blocs/popular_mixes_bloc.dart';
import '../../blocs/popular_mixes_event.dart';
import '../../blocs/popular_mixes_state.dart';
import '../../blocs/ads_bloc.dart';
import '../../blocs/ads_event.dart';
import '../../blocs/ads_state.dart';
import '../../blocs/categories_bloc.dart';
import '../../blocs/categories_event.dart';
import '../../blocs/categories_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => PopularMixesBloc()..add(FetchPopularMixes()),
        ),
        BlocProvider(
          create: (context) => AdsBloc()..add(FetchAds()),
        ),
        BlocProvider(
          create: (context) => CategoriesBloc()..add(FetchCategories()),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Миксы для кальяна'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<AuthBloc>().add(SignOutRequested());
              },
            ),
          ],
        ),
        body: ListView(
          children: const [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: GestureDetector(
                onTap: () => context.go('/search'),
                child: const AbsorbPointer(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Поиск микса...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
              ),
            ),
            CategoriesSection(),
            SizedBox(height: 12),
            AdsSection(),
            SizedBox(height: 12),
            PopularMixesSection(),
          ],
        ),
        // TODO: Add BottomNavigationBar
      ),
    );
  }
}

class CategoriesSection extends StatelessWidget {
  const CategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'Категории',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        BlocBuilder<CategoriesBloc, CategoriesState>(
          builder: (context, state) {
            if (state is CategoriesLoaded) {
              return SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.categories.length,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  itemBuilder: (context, index) {
                    final category = state.categories[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child:                       child: RawChip(
                        label: Text(category.name),
                        onPressed: () {
                          context.go('/categories/${category.name}');
                        },
                        shape: const StadiumBorder(),
                        side: BorderSide(color: Theme.of(context).colorScheme.primary),
                      ),
                    );
                  },
                ),
              );
            }
            return const SizedBox.shrink(); // Initial or loading state
          },
        ),
      ],
    );
  }
}

class AdsSection extends StatelessWidget {
  const AdsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdsBloc, AdsState>(
      builder: (context, state) {
        if (state is AdsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AdsLoaded) {
          if (state.ads.isEmpty) return const SizedBox.shrink();
          return SizedBox(
            height: 150,
            child: PageView.builder(
              itemCount: state.ads.length,
              itemBuilder: (context, index) {
                final ad = state.ads[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(ad.imageUrl, fit: BoxFit.cover),
                );
              },
            ),
          );
        }
        if (state is AdsError) {
          return Center(child: Text(state.message));
        }
        return const SizedBox.shrink(); // Initial state
      },
    );
  }
}

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
            ],
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
