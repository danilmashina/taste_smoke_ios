import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './search_event.dart';
import './search_state.dart';
import '../../data/public_mix.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final FirebaseFirestore _firestore;

  SearchBloc({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        super(SearchInitial()) {
    on<PerformSearch>(_onPerformSearch);
  }

  Future<void> _onPerformSearch(
    PerformSearch event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading());
    try {
      // Basic search: query by name or description containing the search term
      // Firestore doesn't support full-text search directly. For advanced search,
      // you'd typically use a third-party service like Algolia or ElasticSearch.
      // This implementation will do a simple prefix search or exact match.
      final snapshot = await _firestore
          .collection('public_mixes')
          .where('name', isGreaterThanOrEqualTo: event.query)
          .where('name', isLessThan: event.query + '\uf8ff')
          .get();

      final results = snapshot.docs
          .map((doc) => PublicMix.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      emit(SearchResultsLoaded(results));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }
}
