import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './popular_mixes_event.dart';
import './popular_mixes_state.dart';
import '../../data/public_mix.dart';

class PopularMixesBloc extends Bloc<PopularMixesEvent, PopularMixesState> {
  final FirebaseFirestore _firestore;

  PopularMixesBloc({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        super(PopularMixesInitial()) {
    on<FetchPopularMixes>(_onFetchPopularMixes);
  }

  Future<void> _onFetchPopularMixes(
    FetchPopularMixes event,
    Emitter<PopularMixesState> emit,
  ) async {
    emit(PopularMixesLoading());
    try {
      final snapshot = await _firestore
          .collection('public_mixes')
          .orderBy('rating', descending: true)
          .limit(10)
          .get();

      final mixes = snapshot.docs
          .map((doc) => PublicMix.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
          
      emit(PopularMixesLoaded(mixes));
    } catch (e) {
      emit(PopularMixesError(e.toString()));
    }
  }
}
