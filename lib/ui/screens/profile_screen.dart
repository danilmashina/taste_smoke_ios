import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/profile_bloc.dart';
import '../../blocs/profile_event.dart';
import '../../blocs/profile_state.dart';
import '../../blocs/auth_bloc.dart';
import '../../blocs/auth_event.dart';
import '../components/additional_info_dialog.dart';

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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: profile.photoUrl != null
                          ? NetworkImage(profile.photoUrl!)
                          : null,
                      child: profile.photoUrl == null
                          ? const Icon(Icons.person, size: 60)
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile.nickname,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatColumn('Likes', profile.totalLikes.toString()),
                        _buildStatColumn('Followers', profile.followersCount.toString()),
                        _buildStatColumn('Following', profile.followingCount.toString()),
                      ],
                    ),
                    SizedBox(height: verticalSpacing * 2),
                    SizedBox(
                      width: double.infinity,
                      height: buttonHeight,
                      child: ElevatedButton(
                        onPressed: () {
                          context.go('/create-mix');
                        },
                        child: Text(
                          'Создать микс',
                          style: TextStyle(fontSize: textSize),
                        ),
                      ),
                    ),
                    SizedBox(height: verticalSpacing),
                    SizedBox(
                      width: double.infinity,
                      height: buttonHeight,
                      child: OutlinedButton(
                        onPressed: () {
                          context.go('/my-mixes');
                        },
                        child: Text(
                          'Мои миксы',
                          style: TextStyle(fontSize: textSize),
                        ),
                      ),
                    ),
                    SizedBox(height: verticalSpacing),
                    SizedBox(
                      width: double.infinity,
                      height: buttonHeight,
                      child: OutlinedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AdditionalInfoDialog(),
                          );
                        },
                        child: Text(
                          'Дополнительная информация',
                          style: TextStyle(fontSize: textSize),
                        ),
                      ),
                    ),
                    SizedBox(height: verticalSpacing * 2),
                    SizedBox(
                      width: double.infinity,
                      height: buttonHeight,
                      child: TextButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(SignOutRequested());
                        },
                        child: Text(
                          'Выйти',
                          style: TextStyle(
                            fontSize: textSize,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ),
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
}