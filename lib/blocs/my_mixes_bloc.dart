import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './my_mixes_event.dart';
import './my_mixes_state.dart';
import '../../data/private_mix.dart';
import '../../data/tobacco_ingredient.dart';

class MyMixesBloc extends Bloc<MyMixesEvent, MyMixesState> {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  MyMixesBloc({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        super(MyMixesInitial()) {
    on<LoadMyMixes>(_onLoadMyMixes);
    on<UpdateMyMix>(_onUpdateMyMix);
    on<DeleteMyMix>(_onDeleteMyMix);
  }

  Future<void> _onLoadMyMixes(
    LoadMyMixes event,
    Emitter<MyMixesState> emit,
  ) async {
    emit(MyMixesLoading());
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      emit(const MyMixesError('User not logged in'));
      return;
    }

    try {
      _firestore
          .collection('users')
          .doc(user.uid)
          .collection('private_mixes')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen((snapshot) {
        final mixes = snapshot.docs
            .map((doc) => PrivateMix.fromJson(doc.data() as Map<String, dynamic>).copyWith(id: doc.id))
            .toList();
        emit(MyMixesLoaded(mixes));
      });
    } catch (e) {
      emit(MyMixesError(e.toString()));
    }
  }

  Future<void> _onUpdateMyMix(
    UpdateMyMix event,
    Emitter<MyMixesState> emit,
  ) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('private_mixes')
          .doc(event.mixId)
          .update({
            'name': event.newText,
            'description': event.newText, // Assuming name and description are the same
            'ingredients': event.newIngredients.map((i) => (i as TobaccoIngredient).toJson()).toList(),
            'strength': event.newStrength,
          });
    } catch (e) {
      // Handle error, maybe emit a state with error message
      print('Error updating mix: $e');
    }
  }

  Future<void> _onDeleteMyMix(
    DeleteMyMix event,
    Emitter<MyMixesState> emit,
  ) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('private_mixes')
          .doc(event.mixId)
          .delete();
    } catch (e) {
      // Handle error
      print('Error deleting mix: $e');
    }
  }
}
