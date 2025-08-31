import 'package:equatable/equatable.dart';

abstract class PopularMixesEvent extends Equatable {
  const PopularMixesEvent();

  @override
  List<Object> get props => [];
}

class FetchPopularMixes extends PopularMixesEvent {}
