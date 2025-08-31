import 'package:equatable/equatable.dart';

abstract class MixesByCategoryEvent extends Equatable {
  const MixesByCategoryEvent();

  @override
  List<Object> get props => [];
}

class FetchMixesByCategory extends MixesByCategoryEvent {
  final String categoryName;

  const FetchMixesByCategory(this.categoryName);

  @override
  List<Object> get props => [categoryName];
}
