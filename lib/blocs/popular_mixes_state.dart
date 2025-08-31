import 'package:equatable/equatable.dart';
import '../../data/public_mix.dart';

abstract class PopularMixesState extends Equatable {
  const PopularMixesState();

  @override
  List<Object> get props => [];
}

class PopularMixesInitial extends PopularMixesState {}

class PopularMixesLoading extends PopularMixesState {}

class PopularMixesLoaded extends PopularMixesState {
  final List<PublicMix> mixes;

  const PopularMixesLoaded(this.mixes);

  @override
  List<Object> get props => [mixes];
}

class PopularMixesError extends PopularMixesState {
  final String message;

  const PopularMixesError(this.message);

  @override
  List<Object> get props => [message];
}
