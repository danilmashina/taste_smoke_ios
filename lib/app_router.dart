import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_state.dart';
import '../ui/screens/auth_screen.dart';
import '../ui/screens/home_screen.dart';

class AppRouter {
  final AuthBloc authBloc;

  AppRouter(this.authBloc);

  late final GoRouter router = GoRouter(
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) => const HomeScreen(),
      ),
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
