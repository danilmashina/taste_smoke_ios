import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth_bloc.dart';
import '../../blocs/auth_event.dart';
import '../../blocs/auth_state.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is PasswordResetEmailSent) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password reset email sent.')),
              );
            } else if (state is Authenticated) {
              // Navigate to home screen
              // We will implement navigation later
              // For now, just show a success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Signed in as ${state.user.email}')),
              );
            }
          },
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              // In a real app, you might want to navigate away in the Authenticated state
              // but for now, we show the auth form regardless.
              return _buildAuthForm(context, state);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAuthForm(BuildContext context, AuthState state) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Вход / Регистрация',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Пароль'),
              obscureText: true,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  final email = _emailController.text.trim();
                  if (email.isNotEmpty) {
                    context.read<AuthBloc>().add(PasswordResetRequested(email));
                  }
                },
                child: const Text('Забыли пароль?'),
              ),
            ),
            const SizedBox(height: 24),
            if (state is AuthLoading)
              const Center(child: CircularProgressIndicator())
            else
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(SignUpRequested(
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                            ));
                      },
                      child: const Text('Регистрация'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(SignInRequested(
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                            ));
                      },
                      child: const Text('Войти'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}