import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import './blocs/auth_bloc.dart';
import './blocs/auth_state.dart';
import './ui/screens/auth_screen.dart';
import './ui/screens/home_screen.dart';
import './ui/screens/categories_screen.dart';
import './ui/screens/favorites_screen.dart';
import './ui/screens/profile_screen.dart';
import './ui/screens/search_screen.dart';
import './ui/main_scaffold.dart';

class AppRouter {
  final AuthBloc authBloc;

  AppRouter(this.authBloc);

  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: <RouteBase>[
      // The main app navigation shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(navigationShell: navigationShell);
        },
        branches: <StatefulShellBranch>[
          // Branch for the Home tab
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/',
                builder: (BuildContext context, GoRouterState state) =>
                    const HomeScreen(),
                routes: <RouteBase>[
                  // Add search screen as a sub-route of home
                  GoRoute(
                    path: 'search',
                    builder: (BuildContext context, GoRouterState state) =>
                        const SearchScreen(),
                  ),
                ],
              ),
            ],
          ),
          // Branch for the Categories tab
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/categories',
                builder: (BuildContext context, GoRouterState state) =>
                    const CategoriesScreen(),
              ),
            ],
          ),
          // Branch for the Favorites tab
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/favorites',
                builder: (BuildContext context, GoRouterState state) =>
                    const FavoritesScreen(),
              ),
            ],
          ),
          // Branch for the Profile tab
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/profile',
                builder: (BuildContext context, GoRouterState state) =>
                    const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      // The login screen, which is not part of the shell
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) => const AuthScreen(),
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final bool loggedIn = authBloc.state is Authenticated;
      final bool loggingIn = state.matchedLocation == '/login';

      // if the user is not logged in, they need to login
      if (!loggedIn) {
        return '/login';
      }

      // if the user is logged in but still on the login page, send them to
      // the home page
      if (loggingIn) {
        return '/';
      }

      return null; // do not redirect
    },
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
  );
}

// This class is needed to make GoRouter listen to Bloc stream changes
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
