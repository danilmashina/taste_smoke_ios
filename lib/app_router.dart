import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import './blocs/auth_bloc.dart';
import './blocs/auth_state.dart';
import './ui/screens/auth_screen.dart';
import './ui/screens/home_screen.dart';
import './ui/screens/create_mix_screen.dart';
import './ui/screens/my_mixes_screen.dart';
import './ui/screens/category_detail_screen.dart';
import './ui/screens/search_screen.dart';

class AppRouter {
  final AuthBloc authBloc;

  AppRouter(this.authBloc);

  late final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) =>
            const HomeScreen(),
        routes: <RouteBase>[
          GoRoute(
            path: 'search',
            builder: (BuildContext context, GoRouterState state) =>
                const SearchScreen(),
          ),
          GoRoute(
            path: 'categories/:categoryName',
            builder: (BuildContext context, GoRouterState state) {
              final categoryName = state.pathParameters['categoryName']!;
              return CategoryDetailScreen(categoryName: categoryName);
            },
          ),
          GoRoute(
            path: 'create-mix',
            builder: (BuildContext context, GoRouterState state) => const CreateMixScreen(),
          ),
          GoRoute(
            path: 'my-mixes',
            builder: (BuildContext context, GoRouterState state) => const MyMixesScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) => const AuthScreen(),
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final bool loggedIn = authBloc.state is Authenticated;
      final bool loggingIn = state.matchedLocation == '/login';

      if (!loggedIn) {
        return '/login';
      }

      if (loggingIn) {
        return '/';
      }

      return null;
    },
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
