import 'package:equatable/equatable.dart';
import '../../data/public_mix.dart';

abstract class MixesByCategoryState extends Equatable {
  const MixesByCategoryState();

  @override
  List<Object> get props => [];
}

class MixesByCategoryInitial extends MixesByCategoryState {}

class MixesByCategoryLoading extends MixesByCategoryState {}

class MixesByCategoryLoaded extends MixesByCategoryState {
  final List<PublicMix> mixes;

  const MixesByCategoryLoaded(this.mixes);

  @override
  List<Object> get props => [mixes];
}

class MixesByCategoryError extends MixesByCategoryState {
  final String message;

  const MixesByCategoryError(this.message);

  @override
  List<Object> get props => [message];
}
