import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../blocs/profile_bloc.dart';
import '../../blocs/profile_event.dart';
import '../../blocs/profile_state.dart';
import '../../blocs/auth_bloc.dart';
import '../../blocs/auth_event.dart';
import '../components/additional_info_dialog.dart';
import '../theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Методы для определения размеров в зависимости от экрана
  double _getButtonHeight(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final diagonalInches = 
      sqrt(pow(size.width / MediaQuery.of(context).devicePixelRatio, 2) + 
           pow(size.height / MediaQuery.of(context).devicePixelRatio, 2)) / 
      160; // Приблизительное количество пикселей на дюйм
    
    if (diagonalInches < 5.0) return 44.0; // Маленькие экраны
    if (diagonalInches < 6.5) return 56.0; // Стандартные экраны
    return 64.0; // Большие экраны
  }

  // ----- Dynamic level helpers -----
  // Levels based on totalLikes thresholds:
  // 0-9: Начинающий, 10-49: Новичок, 50-99: Любитель, 100-149: Эксперт, 150+: Мастер
  String _levelLabel(int likes) {
    if (likes < 10) {
      return 'Уровень: Начинающий (+${10 - likes})';
    } else if (likes < 50) {
      return 'Уровень: Новичок (+${50 - likes})';
    } else if (likes < 100) {
      return 'Уровень: Любитель (+${100 - likes})';
    } else if (likes < 150) {
      return 'Уровень: Эксперт (+${150 - likes})';
    } else {
      return 'Уровень: Мастер (макс)';
    }
  }

  double _levelProgress(int likes) {
    int start = 0;
    int end = 10;
    if (likes < 10) {
      start = 0; end = 10;
    } else if (likes < 50) {
      start = 10; end = 50;
    } else if (likes < 100) {
      start = 50; end = 100;
    } else if (likes < 150) {
      start = 100; end = 150;
    } else {
      return 1.0;
    }
    final progress = (likes - start) / (end - start);
    return progress.clamp(0.0, 1.0);
  }
  
  double _getHorizontalPadding(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final diagonalInches = 
      sqrt(pow(size.width / MediaQuery.of(context).devicePixelRatio, 2) + 
           pow(size.height / MediaQuery.of(context).devicePixelRatio, 2)) / 
      160;
    
    if (diagonalInches < 5.0) return 12.0;
    if (diagonalInches < 6.5) return 16.0;
    return 20.0;
  }
  
  double _getVerticalSpacing(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final diagonalInches = 
      sqrt(pow(size.width / MediaQuery.of(context).devicePixelRatio, 2) + 
           pow(size.height / MediaQuery.of(context).devicePixelRatio, 2)) / 
      160;
    
    if (diagonalInches < 5.0) return 8.0;
    if (diagonalInches < 6.5) return 12.0;
    return 16.0;
  }
  
  double _getTextSize(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final diagonalInches = 
      sqrt(pow(size.width / MediaQuery.of(context).devicePixelRatio, 2) + 
           pow(size.height / MediaQuery.of(context).devicePixelRatio, 2)) / 
      160;
    
    if (diagonalInches < 5.0) return 14.0;
    if (diagonalInches < 6.5) return 16.0;
    return 18.0;
  }

  @override
  Widget build(BuildContext context) {
    final buttonHeight = _getButtonHeight(context);
    final horizontalPadding = _getHorizontalPadding(context);
    final verticalSpacing = _getVerticalSpacing(context);
    final textSize = _getTextSize(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 360; // iPhone SE/узкие экраны
    final String? email = FirebaseAuth.instance.currentUser?.email;

    return BlocProvider(
      create: (context) => ProfileBloc()..add(LoadProfile()),
      child: Scaffold(
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ProfileLoaded) {
              final profile = state.userProfile;
              return SingleChildScrollView(
                padding: EdgeInsets.all(horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    // Profile Card (as in Android)
                    Card(
                      color: cardBackground,
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 8),
                            Center(
                              child: CircleAvatar(
                                radius: 48,
                                backgroundImage: profile.photoUrl != null && profile.photoUrl!.isNotEmpty
                                    ? NetworkImage(profile.photoUrl!)
                                    : null,
                                child: (profile.photoUrl == null || profile.photoUrl!.isEmpty)
                                    ? const Icon(Icons.person, size: 48)
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: Text(
                                profile.nickname,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: primaryText,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Level row with progress (dynamic from totalLikes)
                            Row(
                              children: [
                                const Icon(Icons.celebration, color: accentPink, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _levelLabel(profile.totalLikes),
                                        style: const TextStyle(color: primaryText, fontSize: 12),
                                      ),
                                      const SizedBox(height: 6),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: _levelProgress(profile.totalLikes),
                                          minHeight: 6,
                                          backgroundColor: Colors.white10,
                                          valueColor: const AlwaysStoppedAnimation<Color>(accentPink),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Stats with icons stacked vertically as rows
                            _statRow(Icons.favorite, 'Лайки', profile.totalLikes.toString()),
                            const SizedBox(height: 6),
                            _statRow(Icons.group, 'Подписчики', profile.followersCount.toString()),
                            const SizedBox(height: 6),
                            _statRow(Icons.person_add, 'Подписки', profile.followingCount.toString()),
                            const SizedBox(height: 12),
                            const Divider(color: Colors.white24),
                            const SizedBox(height: 8),
                            Center(
                              child: Text(
                                email != null && email.isNotEmpty
                                    ? 'Вы вошли как: $email'
                                    : 'Вы вошли',
                                style: const TextStyle(color: secondaryText, fontSize: 12),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: verticalSpacing),
                    // Buttons responsive: wrap to vertical on narrow screens to avoid clipping
                    if (isNarrow) ...[
                      SizedBox(
                        height: buttonHeight,
                        child: ElevatedButton(
                          onPressed: () => context.go('/create-mix'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size.fromHeight(buttonHeight),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text('Создать микс', style: TextStyle(fontSize: textSize)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: buttonHeight,
                        child: OutlinedButton(
                          onPressed: () => context.go('/my-mixes'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size.fromHeight(buttonHeight),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text('Мои миксы', style: TextStyle(fontSize: textSize)),
                          ),
                        ),
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: buttonHeight,
                              child: ElevatedButton(
                                onPressed: () => context.go('/create-mix'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text('Создать микс', style: TextStyle(fontSize: textSize)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: buttonHeight,
                              child: OutlinedButton(
                                onPressed: () => context.go('/my-mixes'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text('Мои миксы', style: TextStyle(fontSize: textSize)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    SizedBox(height: verticalSpacing),
                    // Additional info (full width outlined)
                    SizedBox(
                      height: buttonHeight,
                      child: OutlinedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AdditionalInfoDialog(),
                          );
                        },
                        child: Text('Дополнительная информация', style: TextStyle(fontSize: textSize)),
                      ),
                    ),
                    SizedBox(height: verticalSpacing),
                    // Logout (full width text red - destructive)
                    SizedBox(
                      height: buttonHeight,
                      child: TextButton(
                        onPressed: () => context.read<AuthBloc>().add(SignOutRequested()),
                        child: Text('Выйти', style: TextStyle(fontSize: textSize, color: Colors.redAccent)),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              );
            }
            if (state is ProfileError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text('Welcome to your profile!'));
          },
        ),
      ),
    );
  }

  Widget _buildStatColumn(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(title),
      ],
    );
  }

  // Helper for stat rows with icon and label to match Android design
  Widget _statRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$label: $value',
            style: const TextStyle(fontSize: 14, color: primaryText),
          ),
        ),
      ],
    );
  }
}