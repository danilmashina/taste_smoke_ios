import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './create_mix_event.dart';
import './create_mix_state.dart';
import '../../data/private_mix.dart';
import '../../data/public_mix.dart';

class CreateMixBloc extends Bloc<CreateMixEvent, CreateMixState> {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  CreateMixBloc({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        super(const CreateMixState()) {
    on<DescriptionChanged>(_onDescriptionChanged);
    on<IngredientsChanged>(_onIngredientsChanged);
    on<StrengthChanged>(_onStrengthChanged);
    on<SavePrivateMix>(_onSavePrivateMix);
    on<PublishPublicMix>(_onPublishPublicMix);
  }

  void _onDescriptionChanged(DescriptionChanged event, Emitter<CreateMixState> emit) {
    emit(state.copyWith(description: event.description, status: FormStatus.initial));
  }

  void _onIngredientsChanged(IngredientsChanged event, Emitter<CreateMixState> emit) {
    emit(state.copyWith(ingredients: event.ingredients, status: FormStatus.initial));
  }

  void _onStrengthChanged(StrengthChanged event, Emitter<CreateMixState> emit) {
    emit(state.copyWith(strength: event.strength, status: FormStatus.initial));
  }

  Future<void> _onSavePrivateMix(SavePrivateMix event, Emitter<CreateMixState> emit) async {
    if (!state.isFormValid) return;
    emit(state.copyWith(status: FormStatus.submissionInProgress));
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      emit(state.copyWith(status: FormStatus.submissionFailure, errorMessage: 'User not logged in'));
      return;
    }

    try {
      final newMix = PrivateMix(
        id: '', // Firestore will generate it
        name: state.description, // Using description as name for simplicity
        description: state.description,
        ingredients: state.ingredients,
        strength: state.strength,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('private_mixes')
          .add(newMix.toJson());

      emit(state.copyWith(status: FormStatus.submissionSuccess));
    } catch (e) {
      emit(state.copyWith(status: FormStatus.submissionFailure, errorMessage: e.toString()));
    }
  }

  Future<void> _onPublishPublicMix(PublishPublicMix event, Emitter<CreateMixState> emit) async {
    if (!state.isFormValid) return;
    emit(state.copyWith(status: FormStatus.submissionInProgress));
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      emit(state.copyWith(status: FormStatus.submissionFailure, errorMessage: 'User not logged in'));
      return;
    }

    try {
      // In a real app, we would fetch the author's name from their profile
      final authorName = user.email?.split('@').first ?? 'Anonymous';

      final newMix = PublicMix(
        id: '', // Firestore will generate it
        name: state.description, // Using description as name
        author: authorName,
        authorId: user.uid,
        description: state.description,
        ingredients: state.ingredients,
        strength: state.strength,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        rating: 0,
        reviews: 0,
        likes: 0,
      );

      await _firestore.collection('public_mixes').add(newMix.toJson());

      emit(state.copyWith(status: FormStatus.submissionSuccess));
    } catch (e) {
      emit(state.copyWith(status: FormStatus.submissionFailure, errorMessage: e.toString()));
    }
  }
}
