import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './favorites_event.dart';
import './favorites_state.dart';
import '../../data/public_mix.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FavoritesBloc({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        super(FavoritesInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
  }

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(FavoritesLoading());
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      emit(const FavoritesError('User not logged in'));
      return;
    }

    try {
      // This is a simplified logic. In a real app, you might store favorite IDs
      // in the user's document and then fetch the corresponding mixes.
      // For now, we assume a 'favorites' subcollection on the user document.
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .get();

      final mixes = snapshot.docs
          .map((doc) => PublicMix.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
          
      emit(FavoritesLoaded(mixes));
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }
}
