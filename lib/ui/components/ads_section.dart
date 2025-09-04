import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/ads_bloc.dart';
import '../../blocs/ads_state.dart';

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
