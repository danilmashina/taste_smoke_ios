import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './profile_event.dart';
import './profile_state.dart';
import '../../data/user_profile.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  ProfileBloc({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      emit(const ProfileError('User not logged in'));
      return;
    }

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      if (userDoc.exists) {
        // TODO: Fetch followers, following, and likes counts separately
        final profile = UserProfile.fromMap(user.uid, userDoc.data()!);
        emit(ProfileLoaded(profile));
      } else {
        // Create a default profile if it doesn't exist
        final defaultProfile = UserProfile(
          uid: user.uid,
          nickname: user.email?.split('@').first ?? 'New User',
        );
        await _firestore.collection('users').doc(user.uid).set({
          'nickname': defaultProfile.nickname,
          'photoUrl': null,
          'totalLikes': 0,
        });
        emit(ProfileLoaded(defaultProfile));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
