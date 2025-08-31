import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './mixes_by_category_event.dart';
import './mixes_by_category_state.dart';
import '../../data/public_mix.dart';

class MixesByCategoryBloc extends Bloc<MixesByCategoryEvent, MixesByCategoryState> {
  final FirebaseFirestore _firestore;

  MixesByCategoryBloc({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        super(MixesByCategoryInitial()) {
    on<FetchMixesByCategory>(_onFetchMixesByCategory);
  }

  Future<void> _onFetchMixesByCategory(
    FetchMixesByCategory event,
    Emitter<MixesByCategoryState> emit,
  ) async {
    emit(MixesByCategoryLoading());
    try {
      // This assumes you have a 'category' field in your public_mixes documents
      final snapshot = await _firestore
          .collection('public_mixes')
          .where('category', isEqualTo: event.categoryName)
          .get();

      final mixes = snapshot.docs
          .map((doc) => PublicMix.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
          
      emit(MixesByCategoryLoaded(mixes));
    } catch (e) {
      emit(MixesByCategoryError(e.toString()));
    }
  }
}
