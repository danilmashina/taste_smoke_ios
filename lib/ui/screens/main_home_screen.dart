import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/popular_mixes_bloc.dart';
import '../../blocs/popular_mixes_event.dart';
import '../../blocs/ads_bloc.dart';
import '../../blocs/ads_event.dart';
import '../../blocs/categories_bloc.dart';
import '../../blocs/categories_event.dart';
import '../components/popular_mixes_section.dart';
import '../components/categories_section.dart';
import '../components/ads_section.dart';

class MainHomeScreen extends StatelessWidget {
  const MainHomeScreen({super.key});

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
        body: ListView(
          children: [
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
            const CategoriesSection(),
            const SizedBox(height: 12),
            const AdsSection(),
            const SizedBox(height: 12),
            const PopularMixesSection(),
          ],
        ),
      ),
    );
  }
}
