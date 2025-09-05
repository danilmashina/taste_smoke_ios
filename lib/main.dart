import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import './blocs/auth_bloc.dart';
import './app_router.dart';
import './blocs/auth_event.dart';
import './ui/theme.dart';
import 'firebase_options.dart';

void main() async {
  // Обеспечиваем инициализацию Flutter
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Инициализируем Firebase с обработкой ошибок
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Гарантируем авторизацию для правил Firestore (требуется request.auth != null)
    try {
      final auth = FirebaseAuth.instance;
      if (auth.currentUser == null) {
        final cred = await auth.signInAnonymously();
        print('✅ Вход выполнен анонимно. UID: ${cred.user?.uid}');
      } else {
        print('ℹ️ Уже авторизован. UID: ${auth.currentUser?.uid}');
      }
    } catch (e) {
      print('❌ Ошибка анонимного входа в FirebaseAuth: $e');
    }
    print('✅ Firebase инициализирован успешно');
  } catch (e) {
    print('❌ Ошибка инициализации Firebase: $e');
    // Продолжаем работу даже если Firebase не инициализирован
  }
  
  // Запускаем приложение с обработкой ошибок
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthBloc _authBloc;
  late final AppRouter _appRouter;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  void _initializeApp() {
    try {
      print('🚀 Инициализация AuthBloc...');
      _authBloc = AuthBloc();
      
      print('🚀 Инициализация AppRouter...');
      _appRouter = AppRouter(_authBloc);
      
      print('🚀 Запуск проверки аутентификации...');
      _authBloc.add(CheckAuthStatus());
      
      print('✅ Приложение инициализировано успешно');
    } catch (e) {
      print('❌ Ошибка инициализации приложения: $e');
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Показываем экран ошибки, если что-то пошло не так
    if (_hasError) {
      return MaterialApp(
        title: 'Taste Smoke',
        theme: appTheme,
        home: _buildErrorScreen(),
      );
    }

    return BlocProvider.value(
      value: _authBloc,
      child: MaterialApp.router(
        title: 'Taste Smoke',
        theme: appTheme,
        routerConfig: _appRouter.router,
        // Добавляем обработчик ошибок роутера
        builder: (context, child) {
          return child ?? _buildLoadingScreen();
        },
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: darkBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 24),
              const Text(
                'Ошибка инициализации',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                style: const TextStyle(
                  fontSize: 16,
                  color: secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _hasError = false;
                    _errorMessage = '';
                  });
                  _initializeApp();
                },
                child: const Text('Попробовать снова'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      backgroundColor: darkBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: accentPink),
            SizedBox(height: 24),
            Text(
              'Загрузка...',
              style: TextStyle(
                fontSize: 18,
                color: primaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (!_hasError) {
      _authBloc.close();
    }
    super.dispose();
  }
}
// l