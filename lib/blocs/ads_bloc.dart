import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './ads_event.dart';
import './ads_state.dart';

class AdsBloc extends Bloc<AdsEvent, AdsState> {
  final FirebaseFirestore _firestore;

  AdsBloc({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        super(AdsInitial()) {
    on<FetchAds>(_onFetchAds);
  }

  Future<void> _onFetchAds(
    FetchAds event,
    Emitter<AdsState> emit,
  ) async {
    emit(AdsLoading());
    try {
      final snapshot = await _firestore.collection('ad_banners').get();
      final ads = snapshot.docs
          .map((doc) => AdBanner.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      emit(AdsLoaded(ads));
    } catch (e) {
      emit(AdsError(e.toString()));
    }
  }
}
